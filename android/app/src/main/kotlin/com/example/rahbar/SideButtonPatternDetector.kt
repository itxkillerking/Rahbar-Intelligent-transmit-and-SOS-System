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
    private val requiredTransitions = 4
    private val maxGapBetweenTransitionsMs = 1500L
    private val maxGestureWindowMs = 5000L
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
            Log.d(TAG, "In cooldown, ignoring")
            return
        }

        // Check debounce
        if (transitionTimestamps.isNotEmpty()) {
            val lastTime = transitionTimestamps.last()
            if (now - lastTime < debounceMs) {
                Log.d(TAG, "Duplicate ignored (debounce)")
                return
            }
        }

        // Ignore duplicate identical states
        if (action == lastState) {
            Log.d(TAG, "Duplicate ignored (identical state: \$action)")
            return
        }
        lastState = action
        
        val actionName = if (action == Intent.ACTION_SCREEN_ON) "SCREEN_ON" else "SCREEN_OFF"
        Log.d(TAG, actionName)

        // Check max gap
        if (transitionTimestamps.isNotEmpty() && now - transitionTimestamps.last() > maxGapBetweenTransitionsMs) {
            Log.d(TAG, "timeout reset (gap too large)")
            transitionTimestamps.clear()
        }

        transitionTimestamps.add(now)
        Log.d(TAG, "sequence \${transitionTimestamps.size}/\$requiredTransitions")

        // Check gesture window
        if (now - transitionTimestamps.first() > maxGestureWindowMs) {
            Log.d(TAG, "timeout reset (gesture window too long)")
            transitionTimestamps.clear()
            transitionTimestamps.add(now)
        }

        if (transitionTimestamps.size >= requiredTransitions) {
            Log.d(TAG, "pattern detected")
            transitionTimestamps.clear()
            lastState = null
            lastTriggerTime = now
            
            Log.d(TAG, "silent danger dispatched")
            onTrigger()
        }
    }
}
