import '../../domain/models/fake_call_attempt.dart';
import '../../domain/repositories/fake_call_repository.dart';

class MockFakeCallRepository implements FakeCallRepository {
  final List<FakeCallAttempt> _history = [];

  @override
  Future<List<FakeCallAttempt>> getHistory() async {
    return List.unmodifiable(_history.reversed); // Return newest first
  }

  @override
  Future<void> logAttempt(FakeCallAttempt attempt) async {
    _history.add(attempt);
  }

  @override
  Future<void> clearHistory() async {
    _history.clear();
  }
}
