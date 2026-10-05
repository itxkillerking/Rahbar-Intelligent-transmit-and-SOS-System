abstract class PlatformTriggerService {
  void onNormalEmergencyTriggered(void Function() callback);
  void onSilentDangerTriggered(void Function() callback);
}
