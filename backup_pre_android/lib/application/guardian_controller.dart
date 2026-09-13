import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/guardian.dart';
import 'providers.dart';

class GuardianState {
  final List<Guardian> guardians;
  final bool isLoading;
  final String? error;

  GuardianState({
    this.guardians = const [],
    this.isLoading = false,
    this.error,
  });

  GuardianState copyWith({
    List<Guardian>? guardians,
    bool? isLoading,
    String? error,
  }) {
    return GuardianState(
      guardians: guardians ?? this.guardians,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class GuardianController extends StateNotifier<GuardianState> {
  final Ref _ref;

  GuardianController(this._ref) : super(GuardianState(isLoading: true)) {
    _loadGuardians();
  }

  Future<void> _loadGuardians() async {
    try {
      state = state.copyWith(isLoading: true);
      final repo = _ref.read(guardianRepositoryProvider);
      final guardians = await repo.getGuardians();
      state = state.copyWith(guardians: guardians, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addMockGuardian(String name, String relationship, String phone) async {
    try {
      state = state.copyWith(isLoading: true);
      final repo = _ref.read(guardianRepositoryProvider);
      final newGuardian = Guardian(
        id: '', 
        name: name,
        relationship: relationship,
        phoneNumber: phone,
        isPrimary: state.guardians.isEmpty,
        isVerified: false, 
      );
      await repo.addGuardian(newGuardian);
      await _loadGuardians();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final guardianControllerProvider = StateNotifierProvider<GuardianController, GuardianState>((ref) {
  return GuardianController(ref);
});
