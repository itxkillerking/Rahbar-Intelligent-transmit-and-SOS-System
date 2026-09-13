package com.example.rahbar

import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {
    override fun provideFlutterEngine(context: Context): FlutterEngine? {
        return FlutterEngineCache.getInstance().get("rahbar_engine")
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        val serviceIntent = Intent(this, RahbarProtectionService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(serviceIntent)
        } else {
            startService(serviceIntent)
        }
        
        handleIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        val action = intent?.action
        if (action == "com.example.rahbar.ACTION_RECORD_VIDEO") {
            WidgetFlutterEngineHelper.sendWidgetActionToDart(this, "openVideoCapture")
            intent.action = null // consume
        } else if (action == "com.example.rahbar.ACTION_OPEN_EVIDENCE") {
            WidgetFlutterEngineHelper.sendWidgetActionToDart(this, "openEvidenceScreen")
            intent.action = null // consume
        }
    }
}
