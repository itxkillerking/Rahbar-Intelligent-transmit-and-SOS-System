package com.example.rahbar

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import android.util.Log

class WidgetActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_SOS_FIRST_TAP = "com.example.rahbar.ACTION_SOS_FIRST_TAP"
        const val ACTION_SOS_CONFIRM = "com.example.rahbar.ACTION_SOS_CONFIRM"
        const val ACTION_SOS_CANCEL = "com.example.rahbar.ACTION_SOS_CANCEL"
        const val ACTION_SOS_RESOLVE = "com.example.rahbar.ACTION_SOS_RESOLVE"
        const val ACTION_AUDIO_START = "com.example.rahbar.ACTION_AUDIO_START"
        const val ACTION_AUDIO_STOP = "com.example.rahbar.ACTION_AUDIO_STOP"
    }

    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        Log.d("WidgetActionReceiver", "Received action: $action")

        when (action) {
            ACTION_SOS_FIRST_TAP -> {
                WidgetStateManager.setPendingConfirmation(context, true)
                WidgetUpdater.updateAllWidgets(context)
                // We use a Handler/delayed broadcast in the provider itself or just rely on state
            }
            ACTION_SOS_CANCEL -> {
                WidgetStateManager.setPendingConfirmation(context, false)
                WidgetUpdater.updateAllWidgets(context)
            }
            ACTION_SOS_CONFIRM -> {
                WidgetStateManager.setPendingConfirmation(context, false)
                // We don't instantly set emergencyActive = true. We wait for Dart to sync.
                WidgetFlutterEngineHelper.sendWidgetActionToDart(context, "widgetSOSConfirm")
                WidgetUpdater.updateAllWidgets(context)
            }
            ACTION_SOS_RESOLVE -> {
                WidgetFlutterEngineHelper.sendWidgetActionToDart(context, "widgetSOSResolve")
            }
            ACTION_AUDIO_START -> {
                // Check if audio is already recording. If it is, do nothing.
                if (WidgetStateManager.isAudioRecordingActive(context)) {
                    return
                }

                val hasMicPerm = ContextCompat.checkSelfPermission(
                    context,
                    Manifest.permission.RECORD_AUDIO
                ) == PackageManager.PERMISSION_GRANTED

                if (!hasMicPerm) {
                    WidgetStateManager.setPermissionRequired(context, true)
                    WidgetUpdater.updateAllWidgets(context)
                } else {
                    WidgetStateManager.setPermissionRequired(context, false)
                    WidgetFlutterEngineHelper.sendWidgetActionToDart(context, "widgetStartAudio")
                }
            }
            ACTION_AUDIO_STOP -> {
                WidgetFlutterEngineHelper.sendWidgetActionToDart(context, "widgetStopAudio")
            }
        }
    }
}
