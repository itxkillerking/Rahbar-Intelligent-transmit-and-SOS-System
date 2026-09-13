package com.example.rahbar

import android.app.Application
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor

class RahbarApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        // Safely cache the Flutter Engine so the Protection Service and Widgets
        // can use it independently of the MainActivity lifecycle.
        WidgetFlutterEngineHelper.ensureRahbarFlutterEngine(this)
    }
}
