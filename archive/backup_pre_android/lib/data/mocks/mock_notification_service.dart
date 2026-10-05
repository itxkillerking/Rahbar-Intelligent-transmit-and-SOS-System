import '../../domain/models/emergency.dart';
import '../../domain/services/notification_service.dart';

class MockNotificationService implements NotificationService {
  @override
  Future<void> notifyGuardian(Emergency emergency) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate notifying guardian
  }

  @override
  Future<void> notifyCommandCenter(Emergency emergency) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Simulate notifying command center
  }
}
