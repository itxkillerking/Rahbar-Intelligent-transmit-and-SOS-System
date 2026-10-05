package com.example.rahbar

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import android.util.Log

class SideButtonPatternDetector(
    private val context: Context,
    private val onTrigger: () -> Unit
) : BroadcastReceiver() {

    private val TAG = "RAHBAR_TRIGGER"
    private val requiredTransitions = 2
    private val maxGapBetweenTransitionsMs = 800L
    private val maxGestureWindowMs = 1800L
    private val cooldownMs = 10000L
    private val debounceMs = 120L

    private val transitionTimestamps = mutableListOf<Long>()
    private var lastState: String? = null
    private var lastTriggerTime = 0L

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action != Intent.ACTION_SCREEN_ON && action != Intent.ACTION_SCREEN_OFF) {
            return
        }

        val now = SystemClock.elapsedRealtime()

        // Check cooldown
        if (now - lastTriggerTime < cooldownMs) {
            Log.d(TAG, "rejected: cooldown active")
            return
        }

        // Check debounce
        if (transitionTimestamps.isNotEmpty()) {
            val lastTime = transitionTimestamps.last()
            if (now - lastTime < debounceMs) {
                Log.d(TAG, "rejected: debounce")
                return
            }
        }

        // Ignore duplicate identical states
        if (action == lastState) {
            Log.d(TAG, "rejected: duplicate identical state (\$action)")
            return
        }
        lastState = action
        
        val actionName = if (action == Intent.ACTION_SCREEN_ON) "SCREEN_ON" else "SCREEN_OFF"
        val pm = context.getSystemService(Context.POWER_SERVICE) as? android.os.PowerManager
        val isInteractive = pm?.isInteractive ?: false
        Log.d(TAG, "\$actionName received (isInteractive=\$isInteractive)")

        // Check max gap
        if (transitionTimestamps.isNotEmpty() && now - transitionTimestamps.last() > maxGapBetweenTransitionsMs) {
            Log.d(TAG, "sequence reset: gap timeout")
            transitionTimestamps.clear()
        }

        transitionTimestamps.add(now)
        Log.d(TAG, "candidate event detected. sequence count \${transitionTimestamps.size}/\$requiredTransitions")

        // Check gesture window
        if (now - transitionTimestamps.first() > maxGestureWindowMs) {
            Log.d(TAG, "sequence reset: gesture-window timeout")
            transitionTimestamps.clear()
            transitionTimestamps.add(now)
        }

        if (transitionTimestamps.size >= requiredTransitions) {
            Log.d(TAG, "successful physical-press recognition. final trigger accepted.")
            transitionTimestamps.clear()
            lastState = null
            lastTriggerTime = now
            
            // Vibration feedback
            val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as? android.os.Vibrator
            if (vibrator != null && vibrator.hasVibrator()) {
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
                    vibrator.vibrate(android.os.VibrationEffect.createOneShot(50L, android.os.VibrationEffect.DEFAULT_AMPLITUDE))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(50L)
                }
            }
            
            Log.d(TAG, "silent danger dispatched")
            onTrigger()
        }
    }
}
