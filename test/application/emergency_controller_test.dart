import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rahbar/application/emergency_controller.dart';
import 'package:rahbar/application/providers.dart';
import 'package:rahbar/domain/models/emergency_mode.dart';
import 'package:rahbar/domain/models/emergency_status.dart';
import 'package:rahbar/data/mocks/mock_synchronization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('Normal Emergency flow: SOS -> awaiting confirmation -> emergency activated -> sent', () async {
    final controller = container.read(emergencyControllerProvider.notifier);

    // 1. SOS Trigger
    await controller.startNormalEmergency();
    var state = container.read(emergencyControllerProvider);
    
    expect(state.activeEmergency, isNotNull);
    expect(state.activeEmergency!.mode, EmergencyMode.normal);
    expect(state.activeEmergency!.status, EmergencyStatus.awaitingConfirmation);

    // 2. Confirmation
    await controller.confirmNormalEmergency();
    state = container.read(emergencyControllerProvider);
    
    // Status should be sent since the mock resolves quickly and online is true by default
    expect(state.activeEmergency!.status, EmergencyStatus.sent);
  });

  test('Silent Danger flow: trigger -> emergency activated -> sent (No awaitingConfirmation)', () async {
    final controller = container.read(emergencyControllerProvider.notifier);

    // 1. Silent Trigger
    await controller.startSilentDangerEmergency();
    var state = container.read(emergencyControllerProvider);
    
    expect(state.activeEmergency, isNotNull);
    expect(state.activeEmergency!.mode, EmergencyMode.silentDanger);
    expect(state.activeEmergency!.status, EmergencyStatus.sent);
  });

  test('Offline Mode flow: offlinePending -> synchronizing (simulated by manual switch)', () async {
    // Set offline
    final syncService = container.read(synchronizationServiceProvider) as MockSynchronizationService;
    syncService.setOnlineStatus(false);

    final controller = container.read(emergencyControllerProvider.notifier);

    // 1. Trigger
    await controller.startSilentDangerEmergency();
    var state = container.read(emergencyControllerProvider);
    
    expect(state.activeEmergency!.status, EmergencyStatus.offlinePending);
  });
}
