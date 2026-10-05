import '../models/guardian.dart';

abstract class GuardianRepository {
  Future<List<Guardian>> getGuardians();
  Future<Guardian> addGuardian(Guardian guardian);
  Future<void> removeGuardian(String id);
}
