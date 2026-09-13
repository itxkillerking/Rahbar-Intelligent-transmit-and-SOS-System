package com.example.rahbar

import android.content.Context
import android.content.SharedPreferences

object WidgetStateManager {
    private const val PREFS_NAME = "RahbarWidgetState"
    
    // State keys
    private const val KEY_EMERGENCY_ACTIVE = "emergencyActive"
    private const val KEY_PENDING_CONFIRMATION = "pendingConfirmation"
    private const val KEY_CONFIRMATION_EXPIRES_AT = "confirmationExpiresAt"
    private const val KEY_AUDIO_RECORDING_ACTIVE = "audioRecordingActive"
    private const val KEY_AUDIO_RECORDING_SOURCE = "audioRecordingSource" // manualAudio, normalEmergency, silentDanger
    private const val KEY_PERMISSION_REQUIRED = "permissionRequired"

    private fun getPrefs(context: Context): SharedPreferences {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    }

    fun isEmergencyActive(context: Context): Boolean {
        return getPrefs(context).getBoolean(KEY_EMERGENCY_ACTIVE, false)
    }

    fun setEmergencyActive(context: Context, active: Boolean) {
        getPrefs(context).edit().putBoolean(KEY_EMERGENCY_ACTIVE, active).apply()
    }

    fun isPendingConfirmation(context: Context): Boolean {
        val prefs = getPrefs(context)
        val pending = prefs.getBoolean(KEY_PENDING_CONFIRMATION, false)
        val expiresAt = prefs.getLong(KEY_CONFIRMATION_EXPIRES_AT, 0L)
        if (pending && System.currentTimeMillis() <= expiresAt) {
            return true
        } else if (pending) {
            // Automatically clear if expired
            clearPendingConfirmation(context)
        }
        return false
    }

    fun setPendingConfirmation(context: Context, pending: Boolean, durationMs: Long = 5000L) {
        val editor = getPrefs(context).edit()
        editor.putBoolean(KEY_PENDING_CONFIRMATION, pending)
        if (pending) {
            editor.putLong(KEY_CONFIRMATION_EXPIRES_AT, System.currentTimeMillis() + durationMs)
        } else {
            editor.putLong(KEY_CONFIRMATION_EXPIRES_AT, 0L)
        }
        editor.apply()
    }

    fun clearPendingConfirmation(context: Context) {
        getPrefs(context).edit()
            .putBoolean(KEY_PENDING_CONFIRMATION, false)
            .putLong(KEY_CONFIRMATION_EXPIRES_AT, 0L)
            .apply()
    }

    fun isAudioRecordingActive(context: Context): Boolean {
        return getPrefs(context).getBoolean(KEY_AUDIO_RECORDING_ACTIVE, false)
    }

    fun getAudioRecordingSource(context: Context): String {
        return getPrefs(context).getString(KEY_AUDIO_RECORDING_SOURCE, "unknown") ?: "unknown"
    }

    fun setAudioRecordingState(context: Context, active: Boolean, source: String) {
        getPrefs(context).edit()
            .putBoolean(KEY_AUDIO_RECORDING_ACTIVE, active)
            .putString(KEY_AUDIO_RECORDING_SOURCE, source)
            .apply()
    }
    
    fun isPermissionRequired(context: Context): Boolean {
        return getPrefs(context).getBoolean(KEY_PERMISSION_REQUIRED, false)
    }
    
    fun setPermissionRequired(context: Context, required: Boolean) {
        getPrefs(context).edit().putBoolean(KEY_PERMISSION_REQUIRED, required).apply()
    }
}
