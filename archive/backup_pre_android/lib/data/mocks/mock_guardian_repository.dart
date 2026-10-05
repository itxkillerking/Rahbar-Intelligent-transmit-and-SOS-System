import '../../domain/models/guardian.dart';
import '../../domain/repositories/guardian_repository.dart';

class MockGuardianRepository implements GuardianRepository {
  final List<Guardian> _mockGuardians = [
    Guardian(
      id: 'g_1',
      name: 'Sarah Ahmed',
      relationship: 'Sister',
      phoneNumber: '+92 300 1234567',
      isPrimary: true,
      isVerified: true,
    ),
    Guardian(
      id: 'g_2',
      name: 'Dr. Tariq Mahmood',
      relationship: 'Father',
      phoneNumber: '+92 333 7654321',
      isPrimary: false,
      isVerified: true,
    ),
  ];

  @override
  Future<List<Guardian>> getGuardians() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_mockGuardians);
  }

  @override
  Future<Guardian> addGuardian(Guardian guardian) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newGuardian = guardian.copyWith(id: 'g_${DateTime.now().millisecondsSinceEpoch}');
    _mockGuardians.add(newGuardian);
    return newGuardian;
  }

  @override
  Future<void> removeGuardian(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockGuardians.removeWhere((g) => g.id == id);
  }
}
