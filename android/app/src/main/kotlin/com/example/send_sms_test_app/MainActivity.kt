package com.example.send_sms_test_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var smsStatusHandler: SmsStatusHandler
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize SMS status handler
        smsStatusHandler = SmsStatusHandler()
        smsStatusHandler.setup(this, flutterEngine)
    }
    
    override fun onDestroy() {
        if (::smsStatusHandler.isInitialized) {
            smsStatusHandler.cleanup()
        }
        super.onDestroy()
    }
}
