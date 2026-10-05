import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import '../domain/models/emergency.dart';
import '../domain/models/emergency_mode.dart';
import '../domain/models/emergency_status.dart';
import 'providers.dart';

class EmergencyState {
  final Emergency? activeEmergency;
  final bool isLoading;
  final String? error;

  EmergencyState({
    this.activeEmergency,
    this.isLoading = false,
    this.error,
  });

  EmergencyState copyWith({
    Emergency? activeEmergency,
    bool? isLoading,
    String? error,
  }) {
    return EmergencyState(
      activeEmergency: activeEmergency ?? this.activeEmergency,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class EmergencyController extends StateNotifier<EmergencyState> {
  final Ref _ref;

  EmergencyController(this._ref) : super(EmergencyState()) {
    _initPlatformTriggers();
  }

  void _initPlatformTriggers() {
    final triggerService = _ref.read(platformTriggerServiceProvider);
    triggerService.onNormalEmergencyTriggered(() {
      AppLogger.info('Platform trigger detected: Normal Emergency');
      startNormalEmergency();
    });
    triggerService.onSilentDangerTriggered(() {
      AppLogger.info('Platform trigger detected: Silent Danger');
      startSilentDangerEmergency();
    });
  }

  Future<void> startNormalEmergency() async {
    AppLogger.info('Emergency state changed: triggerDetected (Normal)');
    final emergency = Emergency.create(
      userId: 'user_123',
      mode: EmergencyMode.normal,
      status: EmergencyStatus.triggerDetected,
    );
    
    state = state.copyWith(
      activeEmergency: emergency.copyWith(status: EmergencyStatus.awaitingConfirmation),
    );
    AppLogger.info('Emergency state changed: awaitingConfirmation');
  }

  Future<void> confirmNormalEmergency() async {
    if (state.activeEmergency == null || state.activeEmergency!.mode != EmergencyMode.normal) return;
    
    AppLogger.info('Normal Emergency confirmed by user.');
    await _activateEmergency(state.activeEmergency!.copyWith(status: EmergencyStatus.emergencyActivated));
  }

  void cancelNormalEmergency() {
    AppLogger.info('Normal Emergency cancelled.');
    state = EmergencyState(); // Reset state
  }

  Future<void> startSilentDangerEmergency() async {
    AppLogger.info('Emergency state changed: triggerDetected (Silent)');
    final emergency = Emergency.create(
      userId: 'user_123',
      mode: EmergencyMode.silentDanger,
      status: EmergencyStatus.triggerDetected,
    );

    // Bypasses confirmation
    await _activateEmergency(emergency.copyWith(status: EmergencyStatus.emergencyActivated));
  }

  Future<void> _activateEmergency(Emergency emergency) async {
    AppLogger.info('Emergency state changed: emergencyActivated');
    state = state.copyWith(activeEmergency: emergency, isLoading: true);

    try {
      // 1. Gather location (optional, shouldn't block)
      final locationService = _ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation();
      var currentEmergency = emergency.copyWith(location: location);

      // 2. Local Persistence (Offline-first foundation)
      final repo = _ref.read(emergencyRepositoryProvider);
      await repo.saveEmergencyLocally(currentEmergency);
      AppLogger.info('Local save completed');

      // 3. Synchronization Attempt
      state = state.copyWith(activeEmergency: currentEmergency.copyWith(status: EmergencyStatus.sending));
      AppLogger.info('Synchronization started');

      final syncService = _ref.read(synchronizationServiceProvider);
      final isOnline = await syncService.synchronizeEmergency(currentEmergency);

      if (isOnline) {
        currentEmergency = currentEmergency.copyWith(status: EmergencyStatus.sent);
        AppLogger.info('Synchronization successful');
        
        // 4. Notify Destinations
        final notifyService = _ref.read(notificationServiceProvider);
        await notifyService.notifyGuardian(currentEmergency);
        AppLogger.info('Guardian notification simulated');
        
        await notifyService.notifyCommandCenter(currentEmergency);
        AppLogger.info('Command Center notification simulated');

      } else {
        currentEmergency = currentEmergency.copyWith(status: EmergencyStatus.offlinePending);
        AppLogger.warning('Synchronization failed, device offline. State: offlinePending');
      }

      state = state.copyWith(activeEmergency: currentEmergency, isLoading: false);

    } catch (e) {
      AppLogger.error('Emergency processing failed', e);
      state = state.copyWith(
        activeEmergency: state.activeEmergency?.copyWith(status: EmergencyStatus.failed),
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void resolveEmergency() {
    if (state.activeEmergency != null) {
      AppLogger.info('Emergency state changed: resolved');
      state = state.copyWith(
        activeEmergency: state.activeEmergency!.copyWith(status: EmergencyStatus.resolved),
      );
      // Wait briefly then clear
      Future.delayed(const Duration(seconds: 2), () {
        state = EmergencyState();
      });
    }
  }
}

final emergencyControllerProvider = StateNotifierProvider<EmergencyController, EmergencyState>((ref) {
  return EmergencyController(ref);
});
