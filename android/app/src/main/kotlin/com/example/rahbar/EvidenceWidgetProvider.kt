package com.example.rahbar

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews

import android.util.Log

class EvidenceWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
        try {
            val isRecording = WidgetStateManager.isAudioRecordingActive(context)
            
            Log.d(
                "RahbarWidget",
                "Rendering Evidence widget id=$appWidgetId recording=$isRecording"
            )
            
            val views = RemoteViews(context.packageName, R.layout.widget_evidence)

        val audioSource = WidgetStateManager.getAudioRecordingSource(context)
        val permReq = WidgetStateManager.isPermissionRequired(context)

        views.setViewVisibility(R.id.btn_evidence_audio_action, View.VISIBLE)
        views.setViewVisibility(R.id.btn_evidence_audio_stop, View.GONE)

        if (isRecording) {
            val label = if (audioSource == "manualAudio") "Manual Evidence" else "Emergency Evidence"
            views.setTextViewText(R.id.evidence_audio_status, "● Recording Active\n$label")
            views.setTextColor(R.id.evidence_audio_status, context.getColor(R.color.rahbar_emergency_red))

            // Only allow manual stop if it's manual audio, following Rule 5 constraints
            if (audioSource == "manualAudio") {
                views.setViewVisibility(R.id.btn_evidence_audio_action, View.GONE)
                views.setViewVisibility(R.id.btn_evidence_audio_stop, View.VISIBLE)
                
                val intentStop = Intent(context, WidgetActionReceiver::class.java).apply {
                    action = WidgetActionReceiver.ACTION_AUDIO_STOP
                    putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                }
                views.setOnClickPendingIntent(R.id.btn_evidence_audio_stop, PendingIntent.getBroadcast(
                    context, appWidgetId + 2000, intentStop, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                ))
            } else {
                // Emergency evidence is running, don't show the manual stop & save button at all
                views.setViewVisibility(R.id.btn_evidence_audio_action, View.GONE)
            }
        } else if (permReq) {
            views.setTextViewText(R.id.evidence_audio_status, "Microphone Access Required")
            views.setTextColor(R.id.evidence_audio_status, context.getColor(R.color.rahbar_emergency_red))
            views.setTextViewText(R.id.btn_evidence_audio_action, "OPEN THE RAHBAR")
            
            // Re-route to main app instead of broadcast
            val intentApp = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            views.setOnClickPendingIntent(R.id.btn_evidence_audio_action, PendingIntent.getActivity(
                context, appWidgetId + 3000, intentApp, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ))
        } else {
            views.setTextViewText(R.id.evidence_audio_status, "Not Recording")
            views.setTextColor(R.id.evidence_audio_status, context.getColor(R.color.rahbar_text_secondary))
            views.setTextViewText(R.id.btn_evidence_audio_action, "START AUDIO")

            val intentStart = Intent(context, WidgetActionReceiver::class.java).apply {
                action = WidgetActionReceiver.ACTION_AUDIO_START
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
            }
            views.setOnClickPendingIntent(R.id.btn_evidence_audio_action, PendingIntent.getBroadcast(
                context, appWidgetId + 4000, intentStart, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            ))
        }

        // Setup Record Video (Cold/Warm Start via MainActivity Intent)
        val intentVideo = Intent(context, MainActivity::class.java).apply {
            action = "com.example.rahbar.ACTION_RECORD_VIDEO"
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        views.setOnClickPendingIntent(R.id.btn_evidence_record_video, PendingIntent.getActivity(
            context, appWidgetId + 5000, intentVideo, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        ))

        // Setup Open Evidence
        val intentEvidence = Intent(context, MainActivity::class.java).apply {
            action = "com.example.rahbar.ACTION_OPEN_EVIDENCE"
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        views.setOnClickPendingIntent(R.id.btn_evidence_open, PendingIntent.getActivity(
            context, appWidgetId + 6000, intentEvidence, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        ))

        Log.d("RahbarWidget", "Evidence RemoteViews ready")
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d("RahbarWidget", "Evidence updateAppWidget completed")
        } catch (e: Exception) {
            Log.e("RahbarWidget", "Evidence widget render failed", e)
        }
    }
}
