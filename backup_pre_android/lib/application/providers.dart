import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/repositories/emergency_repository.dart';
import '../domain/services/evidence_service.dart';
import '../domain/services/location_service.dart';
import '../domain/services/notification_service.dart';
import '../domain/services/platform_trigger_service.dart';
import '../domain/services/storage_service.dart';
import '../domain/services/synchronization_service.dart';

import '../data/mocks/mock_emergency_repository.dart';
import '../data/mocks/mock_evidence_service.dart';
import '../data/mocks/mock_location_service.dart';
import '../data/mocks/mock_notification_service.dart';
import '../data/mocks/mock_platform_trigger_service.dart';
import '../data/mocks/mock_storage_service.dart';
import '../data/mocks/mock_synchronization_service.dart';

import '../domain/repositories/guardian_repository.dart';
import '../data/mocks/mock_guardian_repository.dart';

import '../domain/repositories/fake_call_repository.dart';
import '../data/mocks/mock_fake_call_repository.dart';

// Repositories
final emergencyRepositoryProvider = Provider<EmergencyRepository>((ref) {
  return MockEmergencyRepository();
});

final guardianRepositoryProvider = Provider<GuardianRepository>((ref) {
  return MockGuardianRepository();
});

final fakeCallRepositoryProvider = Provider<FakeCallRepository>((ref) {
  return MockFakeCallRepository();
});
// Services
final locationServiceProvider = Provider<LocationService>((ref) {
  return MockLocationService();
});

final evidenceServiceProvider = Provider<EvidenceService>((ref) {
  return MockEvidenceService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return MockNotificationService();
});

final synchronizationServiceProvider = Provider<SynchronizationService>((ref) {
  return MockSynchronizationService();
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return MockStorageService();
});

final platformTriggerServiceProvider = Provider<PlatformTriggerService>((ref) {
  return MockPlatformTriggerService();
});
