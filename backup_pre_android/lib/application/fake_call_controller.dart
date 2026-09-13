import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/fake_call_attempt.dart';
import 'providers.dart';

class FakeCallState {
  final List<FakeCallAttempt> history;
  final bool isBlocked;
  final int attemptsUsed;
  static const int threshold = 4;

  FakeCallState({this.history = const []})
      : attemptsUsed = history.length,
        isBlocked = history.length >= threshold;
}

class FakeCallController extends StateNotifier<FakeCallState> {
  final Ref _ref;

  FakeCallController(this._ref) : super(FakeCallState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _ref.read(fakeCallRepositoryProvider).getHistory();
    state = FakeCallState(history: history);
  }

  Future<bool> triggerFakeCall() async {
    if (state.isBlocked) {
      return false; // Blocked, cannot trigger
    }

    final attempt = FakeCallAttempt(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: DateTime.now(),
      status: 'Simulated Call Generated',
    );

    await _ref.read(fakeCallRepositoryProvider).logAttempt(attempt);
    await _loadHistory();
    return true;
  }

  Future<void> resetPrototype() async {
    await _ref.read(fakeCallRepositoryProvider).clearHistory();
    await _loadHistory();
  }
}

final fakeCallControllerProvider = StateNotifierProvider<FakeCallController, FakeCallState>((ref) {
  return FakeCallController(ref);
});
