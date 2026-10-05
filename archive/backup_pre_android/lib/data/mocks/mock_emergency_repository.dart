import '../../domain/models/emergency.dart';
import '../../domain/repositories/emergency_repository.dart';

class MockEmergencyRepository implements EmergencyRepository {
  Emergency? _localEmergency;

  @override
  Future<void> saveEmergencyLocally(Emergency emergency) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate IO
    _localEmergency = emergency;
  }

  @override
  Future<Emergency?> getLocalEmergency() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate IO
    return _localEmergency;
  }

  @override
  Future<void> clearLocalEmergency() async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate IO
    _localEmergency = null;
  }
}
