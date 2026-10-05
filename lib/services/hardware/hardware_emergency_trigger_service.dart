import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rahbar/application/emergency_controller.dart';
import 'package:rahbar/core/logging/app_logger.dart';

final hardwareEmergencyTriggerServiceProvider = Provider<HardwareEmergencyTriggerService>((ref) {
  final service = HardwareEmergencyTriggerService(ref);
  service.initialize();
  return service;
});

class HardwareEmergencyTriggerService {
  final Ref _ref;
  static const MethodChannel _channel = MethodChannel('com.example.rahbar/hardware_trigger');

  HardwareEmergencyTriggerService(this._ref);

  void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
    AppLogger.info('[HardwareTrigger] Dart service initialized and listening.');
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'silentDangerTrigger') {
      AppLogger.info('[HardwareTrigger] Silent Danger trigger received from native background service.');
      _ref.read(emergencyControllerProvider.notifier).startSilentDangerEmergency();
    }
  }

  Future<void> updateNotification(String title, String text) async {
    try {
      await _channel.invokeMethod('updateNotification', {
        'title': title,
        'text': text,
      });
    } catch (e) {
      AppLogger.error('Failed to update notification', e);
    }
  }
}
