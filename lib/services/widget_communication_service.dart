import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/emergency_controller.dart';
import '../application/evidence_controller.dart';
import '../core/logging/app_logger.dart';
import '../domain/models/evidence.dart';
import '../main.dart'; // for globalNavigatorKey
import '../ui/screens/video_capture_screen.dart';
import '../ui/screens/evidence_screen.dart';

final widgetCommunicationServiceProvider = Provider<WidgetCommunicationService>((ref) {
  final service = WidgetCommunicationService(ref);
  service.initialize();
  return service;
});

class WidgetCommunicationService {
  final Ref _ref;
  static const MethodChannel _channel = MethodChannel('com.example.rahbar/widget_channel');

  WidgetCommunicationService(this._ref);

  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
    // Tell Android that Dart is ready to receive pending widget actions
    _channel.invokeMethod('dartBridgeReady');
    AppLogger.info('[WidgetBridge] Dart service initialized and listening.');
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    AppLogger.info('[WidgetBridge] Received method: ${call.method}');
    switch (call.method) {
      case 'widgetSOSConfirm':
        final emergencyNotifier = _ref.read(emergencyControllerProvider.notifier);
        // Execute actual normal emergency activation via existing path
        await emergencyNotifier.startNormalEmergency();
        await emergencyNotifier.confirmNormalEmergency();
        break;

      case 'widgetSOSResolve':
        final emergencyNotifier = _ref.read(emergencyControllerProvider.notifier);
        await emergencyNotifier.resolveEmergency();
        break;

      case 'widgetStartAudio':
        // The Android side ensures no double-recording occurs and mic permission is granted.
        // We still use the safe standard startRecording method.
        final audioNotifier = _ref.read(audioCaptureControllerProvider.notifier);
        await audioNotifier.startRecording(EvidenceSource.manualAudio);
        break;

      case 'widgetStopAudio':
        final audioNotifier = _ref.read(audioCaptureControllerProvider.notifier);
        await audioNotifier.stopRecording();
        break;

      case 'openVideoCapture':
        _navigateTo(const VideoCaptureScreen());
        break;

      case 'openEvidenceScreen':
        _navigateTo(const EvidenceScreen());
        break;

      default:
        AppLogger.warning('[WidgetBridge] Unknown method: ${call.method}');
    }
  }

  void _navigateTo(Widget screen) {
    if (globalNavigatorKey.currentState != null) {
      // Use pushAndRemoveUntil or push based on preferred UX.
      // A simple push works, but we should make sure we don't stack infinitely.
      globalNavigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => screen),
      );
    } else {
      AppLogger.warning('[WidgetBridge] Navigator state is null. Cannot navigate.');
    }
  }

  Future<void> syncStateToWidgets({
    required bool emergencyActive,
    required bool audioRecordingActive,
    required String audioRecordingSource,
  }) async {
    try {
      await _channel.invokeMethod('syncWidgetState', {
        'emergencyActive': emergencyActive,
        'audioRecordingActive': audioRecordingActive,
        'audioRecordingSource': audioRecordingSource,
      });
      AppLogger.info('[WidgetBridge] State synced to Android widgets.');
    } catch (e) {
      AppLogger.error('[WidgetBridge] Failed to sync state to widgets', e);
    }
  }
}
