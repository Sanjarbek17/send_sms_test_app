package com.example.send_sms_test_app

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.telephony.SmsManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.Manifest
import androidx.core.app.ActivityCompat
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.HashMap

class CustomSmsHandler : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var context: Context? = null
    private var eventSink: EventChannel.EventSink? = null
    private var sentReceiver: BroadcastReceiver? = null
    private var deliveredReceiver: BroadcastReceiver? = null
    private val activeSends = mutableMapOf<String, SmsTrackingInfo>()
    
    companion object {
        private const val TAG = "CustomSmsHandler"
        private const val SMS_SENT_ACTION = "com.example.send_sms_test_app.SMS_SENT"
        private const val SMS_DELIVERED_ACTION = "com.example.send_sms_test_app.SMS_DELIVERED"
    }
    
    data class SmsTrackingInfo(
        val sendId: String,
        val phoneNumber: String,
        val message: String,
        val timestamp: Long
    )
    
    fun setup(context: Context, flutterEngine: FlutterEngine) {
        this.context = context
        
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "custom_sms_channel")
        methodChannel.setMethodCallHandler(this)
        
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "custom_sms_events")
        eventChannel.setStreamHandler(this)
        
        setupBroadcastReceivers()
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "sendSms" -> {
                val phoneNumber = call.argument<String>("phoneNumber")
                val message = call.argument<String>("message")
                val simSlot = call.argument<Int>("simSlot") ?: 0
                
                if (phoneNumber != null && message != null) {
                    sendSms(phoneNumber, message, simSlot, result)
                } else {
                    result.error("INVALID_ARGUMENTS", "Phone number and message are required", null)
                }
            }
            "getSimCards" -> {
                result.success(getAvailableSimCards())
            }
            "hasPermissions" -> {
                result.success(checkSmsPermissions())
            }
            else -> {
                result.notImplemented()
            }
        }
    }
    
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
        Log.d(TAG, "Event channel listener attached")
    }
    
    override fun onCancel(arguments: Any?) {
        this.eventSink = null
        Log.d(TAG, "Event channel listener cancelled")
    }
    
    private fun sendSms(phoneNumber: String, message: String, simSlot: Int, result: MethodChannel.Result) {
        val context = this.context ?: run {
            result.error("NO_CONTEXT", "Context not available", null)
            return
        }
        
        // Check permissions
        if (!checkSmsPermissions()) {
            result.error("PERMISSION_DENIED", "SMS permissions not granted", null)
            return
        }
        
        try {
            val sendId = UUID.randomUUID().toString()
            val trackingInfo = SmsTrackingInfo(
                sendId = sendId,
                phoneNumber = phoneNumber,
                message = message,
                timestamp = System.currentTimeMillis()
            )
            
            activeSends[sendId] = trackingInfo
            
            // Send initial status
            sendStatusUpdate(sendId, phoneNumber, "queued", null)
            
            // Get SMS manager for specific SIM
            val smsManager = getSmsManagerForSim(simSlot)
            
            // Send status update
            sendStatusUpdate(sendId, phoneNumber, "sending", null)
            
            // Send single SMS (messages are limited to 160 characters in Flutter UI)
            val sentIntent = createSentPendingIntent(sendId)
            val deliveredIntent = createDeliveredPendingIntent(sendId)
            
            if (sentIntent == null || deliveredIntent == null) {
                Log.e(TAG, "Failed to create PendingIntents for SMS tracking")
                result.error("SEND_FAILED", "Failed to create SMS tracking intents", null)
                return
            }
            
            Log.d(TAG, "Created PendingIntents for SMS $sendId")
            
            smsManager.sendTextMessage(
                phoneNumber,
                null,
                message,
                sentIntent,
                deliveredIntent
            )
            
            // Return immediately with send ID - actual status will come via event channel
            result.success(hashMapOf(
                "sendId" to sendId,
                "status" to "queued",
                "message" to "SMS queued for sending"
            ))
            
            Log.d(TAG, "SMS queued for sending: $sendId to $phoneNumber")
            
        } catch (e: Exception) {
            result.error("SEND_FAILED", "Failed to send SMS: ${e.message}", null)
            Log.e(TAG, "Failed to send SMS", e)
        }
    }
    
    private fun getSmsManagerForSim(simSlot: Int): SmsManager {
        return if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP_MR1) {
            val subscriptionManager = context?.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
            val subscriptionInfoList = subscriptionManager?.activeSubscriptionInfoList
            
            if (subscriptionInfoList != null && simSlot < subscriptionInfoList.size) {
                val subscriptionId = subscriptionInfoList[simSlot].subscriptionId
                SmsManager.getSmsManagerForSubscriptionId(subscriptionId)
            } else {
                SmsManager.getDefault()
            }
        } else {
            SmsManager.getDefault()
        }
    }
    
    private fun getAvailableSimCards(): List<HashMap<String, Any>> {
        val context = this.context ?: return emptyList()
        val simCards = mutableListOf<HashMap<String, Any>>()
        
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP_MR1) {
            try {
                val subscriptionManager = context.getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as? SubscriptionManager
                val subscriptionInfoList = subscriptionManager?.activeSubscriptionInfoList
                
                subscriptionInfoList?.forEachIndexed { index, subscriptionInfo ->
                    val simCard = hashMapOf<String, Any>(
                        "simSlot" to index,
                        "subscriptionId" to subscriptionInfo.subscriptionId,
                        "carrierName" to (subscriptionInfo.carrierName?.toString() ?: "Unknown"),
                        "displayName" to (subscriptionInfo.displayName?.toString() ?: "SIM ${index + 1}"),
                        "iccId" to (subscriptionInfo.iccId ?: "")
                    )
                    simCards.add(simCard)
                }
            } catch (e: SecurityException) {
                Log.e(TAG, "Permission denied when getting SIM cards", e)
            }
        }
        
        // If no SIM cards found or old Android version, add default
        if (simCards.isEmpty()) {
            simCards.add(hashMapOf(
                "simSlot" to 0,
                "carrierName" to "Default",
                "displayName" to "Default SIM",
                "iccId" to ""
            ))
        }
        
        return simCards
    }
    
    private fun checkSmsPermissions(): Boolean {
        val context = this.context ?: return false
        return ActivityCompat.checkSelfPermission(context, Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED &&
               ActivityCompat.checkSelfPermission(context, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED
    }
    
    private fun setupBroadcastReceivers() {
        val context = this.context ?: return
        
        // SMS Sent Receiver
        sentReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val sendId = intent?.getStringExtra("sendId")
                Log.d(TAG, "SMS Sent broadcast received for sendId: $sendId, resultCode: $resultCode")
                
                if (sendId != null) {
                    val trackingInfo = activeSends[sendId]
                    if (trackingInfo != null) {
                        when (resultCode) {
                            Activity.RESULT_OK -> {
                                handleSentStatus(sendId, trackingInfo, true)
                            }
                            SmsManager.RESULT_ERROR_GENERIC_FAILURE -> {
                                handleSentStatus(sendId, trackingInfo, false, "Generic failure")
                            }
                            SmsManager.RESULT_ERROR_NO_SERVICE -> {
                                handleSentStatus(sendId, trackingInfo, false, "No service")
                            }
                            SmsManager.RESULT_ERROR_NULL_PDU -> {
                                handleSentStatus(sendId, trackingInfo, false, "Invalid message format")
                            }
                            SmsManager.RESULT_ERROR_RADIO_OFF -> {
                                handleSentStatus(sendId, trackingInfo, false, "Radio is off")
                            }
                            else -> {
                                handleSentStatus(sendId, trackingInfo, false, "Unknown error: $resultCode")
                            }
                        }
                    } else {
                        Log.w(TAG, "No tracking info found for sendId: $sendId")
                    }
                } else {
                    Log.w(TAG, "SMS Sent broadcast received without sendId")
                }
            }
        }
        
        // SMS Delivered Receiver
        deliveredReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val sendId = intent?.getStringExtra("sendId")
                Log.d(TAG, "SMS Delivered broadcast received for sendId: $sendId, resultCode: $resultCode")
                
                if (sendId != null) {
                    val trackingInfo = activeSends[sendId]
                    if (trackingInfo != null) {
                        when (resultCode) {
                            Activity.RESULT_OK -> {
                                handleDeliveredStatus(sendId, trackingInfo, true)
                            }
                            Activity.RESULT_CANCELED -> {
                                handleDeliveredStatus(sendId, trackingInfo, false, "Delivery failed")
                            }
                            else -> {
                                handleDeliveredStatus(sendId, trackingInfo, false, "Unknown delivery error: $resultCode")
                            }
                        }
                    } else {
                        // This is normal - SMS was already marked as "sent" and removed from tracking
                        Log.d(TAG, "Delivery status received for already completed SMS: $sendId")
                    }
                } else {
                    Log.w(TAG, "SMS Delivered broadcast received without sendId")
                }
            }
        }
        
        // Register receivers
        try {
            val sentIntentFilter = IntentFilter(SMS_SENT_ACTION)
            val deliveredIntentFilter = IntentFilter(SMS_DELIVERED_ACTION)
            
            context.registerReceiver(sentReceiver, sentIntentFilter)
            context.registerReceiver(deliveredReceiver, deliveredIntentFilter)
            
            Log.d(TAG, "SMS broadcast receivers registered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register SMS receivers: ${e.message}")
        }
    }
    
    private fun createSentPendingIntent(sendId: String): PendingIntent? {
        val context = this.context ?: return null
        
        val sentIntent = Intent(SMS_SENT_ACTION).apply {
            putExtra("sendId", sendId)
        }
        
        // Use a unique request code to avoid conflicts between concurrent SMS sends
        // Combine timestamp with hash code to ensure uniqueness
        val requestCode = (System.currentTimeMillis() and 0xFFFF).toInt() + sendId.hashCode()
        
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            sentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    private fun createDeliveredPendingIntent(sendId: String): PendingIntent? {
        val context = this.context ?: return null
        
        val deliveredIntent = Intent(SMS_DELIVERED_ACTION).apply {
            putExtra("sendId", sendId)
        }
        
        // Use a unique request code to avoid conflicts between concurrent SMS sends
        // Add offset and timestamp to ensure uniqueness from sent intent
        val requestCode = (System.currentTimeMillis() and 0xFFFF).toInt() + sendId.hashCode() + 10000
        
        return PendingIntent.getBroadcast(
            context,
            requestCode,
            deliveredIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    private fun sendStatusUpdate(sendId: String, phoneNumber: String, status: String, errorMessage: String?) {
        val statusData = HashMap<String, Any>().apply {
            put("sendId", sendId)
            put("phoneNumber", phoneNumber)
            put("status", status)
            put("timestamp", System.currentTimeMillis())
            errorMessage?.let { put("errorMessage", it) }
        }
        
        eventSink?.success(statusData)
        Log.d(TAG, "Status update: $status for $phoneNumber (ID: $sendId)")
    }
    
    private fun handleSentStatus(sendId: String, trackingInfo: SmsTrackingInfo, success: Boolean, errorMessage: String? = null) {
        if (success) {
            sendStatusUpdate(sendId, trackingInfo.phoneNumber, "sent", null)
            // Remove from active tracking since SMS was sent successfully
            // Delivery status tracking is optional and shouldn't block new SMS sends
            activeSends.remove(sendId)
            Log.d(TAG, "SMS sent successfully: $sendId")
        } else {
            sendStatusUpdate(sendId, trackingInfo.phoneNumber, "failed", errorMessage)
            activeSends.remove(sendId)
            Log.d(TAG, "SMS failed to send: $sendId - $errorMessage")
        }
    }
    
    private fun handleDeliveredStatus(sendId: String, trackingInfo: SmsTrackingInfo, success: Boolean, errorMessage: String? = null) {
        if (success) {
            sendStatusUpdate(sendId, trackingInfo.phoneNumber, "delivered", null)
            activeSends.remove(sendId)
            Log.d(TAG, "SMS delivered successfully: $sendId")
        } else {
            sendStatusUpdate(sendId, trackingInfo.phoneNumber, "failed", errorMessage)
            activeSends.remove(sendId)
            Log.d(TAG, "SMS delivery failed: $sendId - $errorMessage")
        }
    }
    
    fun cleanup() {
        val context = this.context ?: return
        
        try {
            sentReceiver?.let { context.unregisterReceiver(it) }
            deliveredReceiver?.let { context.unregisterReceiver(it) }
            Log.d(TAG, "SMS broadcast receivers unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unregister SMS receivers: ${e.message}")
        }
        
        activeSends.clear()
        eventSink = null
        this.context = null
    }
}