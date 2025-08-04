package com.example.send_sms_test_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var customSmsHandler: CustomSmsHandler
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize custom SMS handler
        customSmsHandler = CustomSmsHandler()
        customSmsHandler.setup(this, flutterEngine)
    }
    
    override fun onDestroy() {
        if (::customSmsHandler.isInitialized) {
            customSmsHandler.cleanup()
        }
        super.onDestroy()
    }
}
