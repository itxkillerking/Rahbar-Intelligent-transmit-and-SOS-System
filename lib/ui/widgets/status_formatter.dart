import '../../domain/models/emergency_status.dart';

class StatusFormatter {
  static String formatEmergencyStatus(EmergencyStatus status) {
    switch (status) {
      case EmergencyStatus.idle:
        return 'Protected';
      case EmergencyStatus.triggerDetected:
        return 'Trigger detected';
      case EmergencyStatus.awaitingConfirmation:
        return 'Awaiting confirmation';
      case EmergencyStatus.emergencyActivated:
        return 'Emergency active';
      case EmergencyStatus.sending:
        return 'Sending alert';
      case EmergencyStatus.sent:
        return 'Alert sent';
      case EmergencyStatus.offlinePending:
        return 'Pending sync';
      case EmergencyStatus.synchronizing:
        return 'Synchronizing';
      case EmergencyStatus.resolved:
        return 'Resolved';
      case EmergencyStatus.failed:
        return 'Failed';
    }
  }
}
