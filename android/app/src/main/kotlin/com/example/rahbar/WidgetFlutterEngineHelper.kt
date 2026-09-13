package com.example.rahbar

import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import android.util.Log

object WidgetFlutterEngineHelper {
    private const val ENGINE_ID = "rahbar_engine"
    const val WIDGET_CHANNEL = "com.example.rahbar/widget_channel"
    
    // We use a lock to ensure engine initialization is completely idempotent 
    // and safe against concurrent calls from broadcast receivers or application creation.
    private val engineLock = Any()
    
    private var isDartReady = false
    private var pendingWidgetAction: String? = null
    private var channel: MethodChannel? = null
    private var contextRef: Context? = null

    /**
     * Safely retrieves the cached engine or creates one if it does not exist.
     * Ensures only ONE engine is created globally.
     */
    fun ensureRahbarFlutterEngine(context: Context): FlutterEngine {
        // First quick check outside sync block
        var engine = FlutterEngineCache.getInstance().get(ENGINE_ID)
        if (engine != null) {
            return engine
        }

        synchronized(engineLock) {
            // Double-checked locking
            engine = FlutterEngineCache.getInstance().get(ENGINE_ID)
            if (engine != null) {
                return engine!!
            }

            // Create the new engine
            val newEngine = FlutterEngine(context.applicationContext)
            
            // Execute Dart entrypoint
            newEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

            // Cache it
            FlutterEngineCache.getInstance().put(ENGINE_ID, newEngine)
            
            setupMethodChannel(newEngine, context)
            
            return newEngine
        }
    }
    
    private fun setupMethodChannel(engine: FlutterEngine, context: Context) {
        contextRef = context.applicationContext
        if (channel == null) {
            channel = MethodChannel(engine.dartExecutor.binaryMessenger, WIDGET_CHANNEL)
            channel?.setMethodCallHandler { call, result ->
                when (call.method) {
                    "dartBridgeReady" -> {
                        Log.d("WidgetBridge", "Dart bridge is ready.")
                        isDartReady = true
                        
                        // Push any pending action
                        pendingWidgetAction?.let { action ->
                            Log.d("WidgetBridge", "Pushing queued action to Dart: $action")
                            channel?.invokeMethod(action, null)
                            pendingWidgetAction = null
                        }
                        result.success(null)
                    }
                    "syncWidgetState" -> {
                        val active = call.argument<Boolean>("emergencyActive") ?: false
                        val audioRecording = call.argument<Boolean>("audioRecordingActive") ?: false
                        val audioSource = call.argument<String>("audioRecordingSource") ?: "unknown"
                        
                        contextRef?.let { ctx ->
                            WidgetStateManager.setEmergencyActive(ctx, active)
                            WidgetStateManager.setAudioRecordingState(ctx, audioRecording, audioSource)
                            
                            // Re-render widgets
                            WidgetUpdater.updateAllWidgets(ctx)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }
    
    fun sendWidgetActionToDart(context: Context, action: String) {
        ensureRahbarFlutterEngine(context) // Ensure engine is alive and channel is set up
        if (channel == null) {
            setupMethodChannel(FlutterEngineCache.getInstance().get(ENGINE_ID)!!, context)
        }
        
        if (isDartReady) {
            Log.d("WidgetBridge", "Dart ready, sending action immediately: $action")
            channel?.invokeMethod(action, null)
        } else {
            Log.d("WidgetBridge", "Dart not ready, queuing action: $action")
            pendingWidgetAction = action
        }
    }
}
