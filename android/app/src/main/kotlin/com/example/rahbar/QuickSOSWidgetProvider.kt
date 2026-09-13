package com.example.rahbar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import android.os.Handler
import android.os.Looper

import android.util.Log

class QuickSOSWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val isEmergencyActive = WidgetStateManager.isEmergencyActive(context)
            val isPendingConfirm = WidgetStateManager.isPendingConfirmation(context)
            val isAudioRecording = WidgetStateManager.isAudioRecordingActive(context)
            
            Log.d(
                "RahbarWidget",
                "Rendering Quick SOS widget id=$appWidgetId active=$isEmergencyActive pending=$isPendingConfirm"
            )
            
            val views = RemoteViews(context.packageName, R.layout.widget_quick_sos)

        // Clear all visibilities
        views.setViewVisibility(R.id.sos_state_normal, View.GONE)
        views.setViewVisibility(R.id.sos_state_confirm, View.GONE)
        views.setViewVisibility(R.id.sos_state_active, View.GONE)

        if (isEmergencyActive) {
            views.setViewVisibility(R.id.sos_state_active, View.VISIBLE)
            views.setTextViewText(R.id.sos_audio_status, if (isAudioRecording) "Recording..." else "Unavailable / Not Recording")
            
            val intentResolve = Intent(context, WidgetActionReceiver::class.java).apply {
                action = WidgetActionReceiver.ACTION_SOS_RESOLVE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            views.setOnClickPendingIntent(R.id.btn_sos_resolve, PendingIntent.getBroadcast(
                context, appWidgetId, intentResolve, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ))
        } else if (isPendingConfirm) {
            views.setViewVisibility(R.id.sos_state_confirm, View.VISIBLE)
            
            val intentConfirm = Intent(context, WidgetActionReceiver::class.java).apply {
                action = WidgetActionReceiver.ACTION_SOS_CONFIRM
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            views.setOnClickPendingIntent(R.id.btn_sos_not_ok, PendingIntent.getBroadcast(
                context, appWidgetId, intentConfirm, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ))

            val intentCancel = Intent(context, WidgetActionReceiver::class.java).apply {
                action = WidgetActionReceiver.ACTION_SOS_CANCEL
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            views.setOnClickPendingIntent(R.id.btn_sos_im_safe, PendingIntent.getBroadcast(
                context, appWidgetId + 1000, intentCancel, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ))
            
            // Post a delayed redraw in case the user doesn't click anything, so it resets visually.
            // The true safety relies on the expiry timestamp in SharedPreferences.
            Handler(Looper.getMainLooper()).postDelayed({
                val updatedConfirm = WidgetStateManager.isPendingConfirmation(context)
                if (!updatedConfirm) {
                    WidgetUpdater.updateAllWidgets(context)
                }
            }, 5500)
        } else {
            views.setViewVisibility(R.id.sos_state_normal, View.VISIBLE)
            
            val intentFirstTap = Intent(context, WidgetActionReceiver::class.java).apply {
                action = WidgetActionReceiver.ACTION_SOS_FIRST_TAP
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            views.setOnClickPendingIntent(R.id.btn_sos_initial, PendingIntent.getBroadcast(
                context, appWidgetId, intentFirstTap, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ))
        }

        Log.d("RahbarWidget", "Quick SOS RemoteViews ready")
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d("RahbarWidget", "Quick SOS updateAppWidget completed")
        } catch (e: Exception) {
            Log.e("RahbarWidget", "Quick SOS widget render failed", e)
        }
    }
}
