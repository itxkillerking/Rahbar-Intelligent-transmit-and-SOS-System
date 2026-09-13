import '../models/emergency.dart';

abstract class EmergencyRepository {
  Future<void> saveEmergencyLocally(Emergency emergency);
  Future<Emergency?> getLocalEmergency();
  Future<void> clearLocalEmergency();
}
