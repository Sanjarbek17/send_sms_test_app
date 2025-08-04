package com.example.send_sms_test_app

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.telephony.SmsManager
import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*
import kotlin.collections.HashMap

class SmsStatusHandler : MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
    private var context: Context? = null
    private var eventSink: EventChannel.EventSink? = null
    private var sentReceiver: BroadcastReceiver? = null
    private var deliveredReceiver: BroadcastReceiver? = null
    private val trackingMap = mutableMapOf<String, TrackingInfo>()
    
    companion object {
        private const val TAG = "SmsStatusHandler"
        private const val SMS_SENT_ACTION = "SMS_SENT"
        private const val SMS_DELIVERED_ACTION = "SMS_DELIVERED"
    }
    
    data class TrackingInfo(
        val trackingId: String,
        val phoneNumber: String,
        val messageText: String,
        val timestamp: Long
    )
    
    fun setup(context: Context, flutterEngine: FlutterEngine) {
        this.context = context
        
        val methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_status_channel")
        methodChannel.setMethodCallHandler(this)
        
        val eventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "sms_status_event_channel")
        eventChannel.setStreamHandler(this)
        
        setupBroadcastReceivers()
    }
    
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startTracking" -> {
                val phoneNumber = call.argument<String>("phoneNumber")
                val messageText = call.argument<String>("messageText")
                
                if (phoneNumber != null && messageText != null) {
                    val trackingId = startTracking(phoneNumber, messageText)
                    result.success(trackingId)
                } else {
                    result.error("INVALID_ARGUMENTS", "Phone number and message text are required", null)
                }
            }
            "stopTracking" -> {
                stopTracking()
                result.success(null)
            }
            "isSupported" -> {
                result.success(true) // SMS status tracking is supported on Android
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
    
    private fun startTracking(phoneNumber: String, messageText: String): String {
        val trackingId = UUID.randomUUID().toString()
        val trackingInfo = TrackingInfo(
            trackingId = trackingId,
            phoneNumber = phoneNumber,
            messageText = messageText,
            timestamp = System.currentTimeMillis()
        )
        
        trackingMap[trackingId] = trackingInfo
        
        // Send initial queued status
        sendStatusUpdate(trackingId, phoneNumber, "queued", null)
        
        Log.d(TAG, "Started tracking SMS: $trackingId for $phoneNumber")
        return trackingId
    }
    
    private fun stopTracking() {
        trackingMap.clear()
        Log.d(TAG, "Stopped all SMS tracking")
    }
    
    private fun setupBroadcastReceivers() {
        val context = this.context ?: return
        
        // SMS Sent Receiver
        sentReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val trackingId = intent?.getStringExtra("trackingId")
                if (trackingId != null) {
                    val trackingInfo = trackingMap[trackingId]
                    if (trackingInfo != null) {
                        when (resultCode) {
                            Activity.RESULT_OK -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "sent", null)
                                Log.d(TAG, "SMS sent successfully: $trackingId")
                            }
                            SmsManager.RESULT_ERROR_GENERIC_FAILURE -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "failed", "Generic failure")
                                Log.e(TAG, "SMS failed - Generic failure: $trackingId")
                            }
                            SmsManager.RESULT_ERROR_NO_SERVICE -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "failed", "No service")
                                Log.e(TAG, "SMS failed - No service: $trackingId")
                            }
                            SmsManager.RESULT_ERROR_NULL_PDU -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "failed", "Null PDU")
                                Log.e(TAG, "SMS failed - Null PDU: $trackingId")
                            }
                            SmsManager.RESULT_ERROR_RADIO_OFF -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "failed", "Radio off")
                                Log.e(TAG, "SMS failed - Radio off: $trackingId")
                            }
                            else -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "failed", "Unknown error: $resultCode")
                                Log.e(TAG, "SMS failed - Unknown error: $resultCode for $trackingId")
                            }
                        }
                    }
                }
            }
        }
        
        // SMS Delivered Receiver
        deliveredReceiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                val trackingId = intent?.getStringExtra("trackingId")
                if (trackingId != null) {
                    val trackingInfo = trackingMap[trackingId]
                    if (trackingInfo != null) {
                        when (resultCode) {
                            Activity.RESULT_OK -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "delivered", null)
                                Log.d(TAG, "SMS delivered successfully: $trackingId")
                                // Remove from tracking map as it's completed
                                trackingMap.remove(trackingId)
                            }
                            Activity.RESULT_CANCELED -> {
                                sendStatusUpdate(trackingId, trackingInfo.phoneNumber, "failed", "Delivery failed")
                                Log.e(TAG, "SMS delivery failed: $trackingId")
                                // Remove from tracking map as it failed
                                trackingMap.remove(trackingId)
                            }
                        }
                    }
                }
            }
        }
        
        // Register receivers
        try {
            val sentIntentFilter = IntentFilter(SMS_SENT_ACTION)
            val deliveredIntentFilter = IntentFilter(SMS_DELIVERED_ACTION)
            
            context.registerReceiver(sentReceiver, sentIntentFilter)
            context.registerReceiver(deliveredReceiver, deliveredIntentFilter)
            
            Log.d(TAG, "SMS status broadcast receivers registered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to register SMS status receivers: ${e.message}")
        }
    }
    
    private fun sendStatusUpdate(trackingId: String, phoneNumber: String, status: String, errorMessage: String?) {
        val statusData = HashMap<String, Any>().apply {
            put("trackingId", trackingId)
            put("phoneNumber", phoneNumber)
            put("status", status)
            put("timestamp", System.currentTimeMillis())
            errorMessage?.let { put("errorMessage", it) }
        }
        
        eventSink?.success(statusData)
        Log.d(TAG, "Sent status update: $status for $trackingId")
    }
    
    fun createSentPendingIntent(trackingId: String): PendingIntent? {
        val context = this.context ?: return null
        
        val sentIntent = Intent(SMS_SENT_ACTION).apply {
            putExtra("trackingId", trackingId)
        }
        
        return PendingIntent.getBroadcast(
            context,
            trackingId.hashCode(),
            sentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    fun createDeliveredPendingIntent(trackingId: String): PendingIntent? {
        val context = this.context ?: return null
        
        val deliveredIntent = Intent(SMS_DELIVERED_ACTION).apply {
            putExtra("trackingId", trackingId)
        }
        
        return PendingIntent.getBroadcast(
            context,
            trackingId.hashCode() + 1000, // Offset to avoid conflicts
            deliveredIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }
    
    fun cleanup() {
        val context = this.context ?: return
        
        try {
            sentReceiver?.let { context.unregisterReceiver(it) }
            deliveredReceiver?.let { context.unregisterReceiver(it) }
            Log.d(TAG, "SMS status broadcast receivers unregistered")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to unregister SMS status receivers: ${e.message}")
        }
        
        trackingMap.clear()
        eventSink = null
        this.context = null
    }
}
