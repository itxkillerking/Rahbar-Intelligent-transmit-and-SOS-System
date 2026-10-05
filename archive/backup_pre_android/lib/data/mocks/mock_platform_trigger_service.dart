import '../../domain/services/platform_trigger_service.dart';

class MockPlatformTriggerService implements PlatformTriggerService {
  void Function()? _normalCallback;
  void Function()? _silentCallback;

  @override
  void onNormalEmergencyTriggered(void Function() callback) {
    _normalCallback = callback;
  }

  @override
  void onSilentDangerTriggered(void Function() callback) {
    _silentCallback = callback;
  }

  // Methods for development controls to trigger events
  void simulateNormalTrigger() {
    _normalCallback?.call();
  }

  void simulateSilentTrigger() {
    _silentCallback?.call();
  }
}
