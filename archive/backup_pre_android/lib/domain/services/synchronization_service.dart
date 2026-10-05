import '../models/emergency.dart';

abstract class SynchronizationService {
  Future<bool> synchronizeEmergency(Emergency emergency);
  Future<bool> checkConnection();
}
