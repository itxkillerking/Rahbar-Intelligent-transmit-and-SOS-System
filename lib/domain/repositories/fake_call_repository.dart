import '../models/fake_call_attempt.dart';

abstract class FakeCallRepository {
  Future<List<FakeCallAttempt>> getHistory();
  Future<void> logAttempt(FakeCallAttempt attempt);
  Future<void> clearHistory();
}
