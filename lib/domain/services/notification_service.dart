import '../models/emergency.dart';

abstract class NotificationService {
  Future<void> notifyGuardian(Emergency emergency);
  Future<void> notifyCommandCenter(Emergency emergency);
}
