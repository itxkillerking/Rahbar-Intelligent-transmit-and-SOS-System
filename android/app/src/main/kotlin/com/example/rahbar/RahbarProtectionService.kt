package com.example.rahbar

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class RahbarProtectionService : Service() {
    private val CHANNEL_ID = "RahbarProtectionChannel"
    private var detector: SideButtonPatternDetector? = null

    override fun onCreate() {
        super.onCreate()
        Log.d("RAHBAR_TRIGGER", "RahbarProtectionService created")
        createNotificationChannel()
        
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("RAHBAR Protection Active")
            .setContentText("Emergency protection is running.")
            .setSmallIcon(android.R.drawable.ic_secure)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
            
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                startForeground(1001, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
            } catch (e: Exception) {
                startForeground(1001, notification)
            }
        } else {
            startForeground(1001, notification)
        }

        val engine = FlutterEngineCache.getInstance().get("rahbar_engine")
        val channel = engine?.let { MethodChannel(it.dartExecutor.binaryMessenger, "com.example.rahbar/hardware_trigger") }
        if (channel == null) {
            Log.e("RAHBAR_TRIGGER", "Failed to get cached FlutterEngine")
        }

        channel?.setMethodCallHandler { call, result ->
            if (call.method == "updateNotification") {
                val title = call.argument<String>("title") ?: "RAHBAR"
                val text = call.argument<String>("text") ?: ""
                updateNotification(title, text)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

        detector = SideButtonPatternDetector(this) {
            Log.d("RAHBAR_TRIGGER", "silent danger dispatched to Flutter")
            // Ensure method channel calls are on the main thread
            Handler(Looper.getMainLooper()).post {
                channel?.invokeMethod("silentDangerTrigger", null)
            }
        }
        
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_SCREEN_ON)
            addAction(Intent.ACTION_SCREEN_OFF)
        }
        registerReceiver(detector, filter)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("RAHBAR_TRIGGER", "RahbarProtectionService onStartCommand")
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d("RAHBAR_TRIGGER", "RahbarProtectionService destroyed")
        detector?.let { unregisterReceiver(it) }
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "RAHBAR Protection Service",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Runs the hardware emergency trigger in the background"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun updateNotification(title: String, text: String) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_secure)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(1001, notification)
    }
}
