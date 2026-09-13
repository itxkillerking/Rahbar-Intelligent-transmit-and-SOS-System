import '../../domain/models/emergency.dart';
import '../../domain/services/synchronization_service.dart';

class MockSynchronizationService implements SynchronizationService {
  bool _isOnline = true;

  void setOnlineStatus(bool isOnline) {
    _isOnline = isOnline;
  }

  @override
  Future<bool> synchronizeEmergency(Emergency emergency) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network request
    return _isOnline;
  }

  @override
  Future<bool> checkConnection() async {
    return _isOnline;
  }
}
