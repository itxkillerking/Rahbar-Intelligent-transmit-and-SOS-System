import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/logging/app_logger.dart';
import '../domain/models/emergency.dart';
import '../domain/models/emergency_mode.dart';
import '../domain/models/emergency_status.dart';
import '../domain/models/evidence.dart';
import '../services/hardware_emergency_trigger_service.dart';
import '../services/widget_communication_service.dart';
import 'evidence_controller.dart';
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
    if (state.activeEmergency != null && 
        (state.activeEmergency!.status == EmergencyStatus.sending || 
         state.activeEmergency!.status == EmergencyStatus.sent ||
         state.activeEmergency!.status == EmergencyStatus.offlinePending ||
         state.activeEmergency!.status == EmergencyStatus.emergencyActivated)) {
      AppLogger.info('Silent Danger trigger ignored: Emergency already active and processing.');
      return;
    }

    AppLogger.info('Emergency state changed: triggerDetected (Silent)');
    final emergency = Emergency.create(
      userId: 'user_123',
      mode: EmergencyMode.silentDanger,
      status: EmergencyStatus.triggerDetected,
    );

    // Bypasses confirmation (escalates if awaitingConfirmation)
    await _activateEmergency(emergency.copyWith(status: EmergencyStatus.emergencyActivated));

    // Update hardware notification and start audio
    _ref.read(hardwareEmergencyTriggerServiceProvider).updateNotification(
      'Emergency Activated',
      'Instant Help is active. Audio evidence recording has started.',
    );
    
    final recordingStarted = await _ref.read(audioCaptureControllerProvider.notifier)
        .startRecording(EvidenceSource.silentDanger, emergencyId: emergency.emergencyId);
        
    if (!recordingStarted) {
      // If mic failed, correct the notification to not lie
      _ref.read(hardwareEmergencyTriggerServiceProvider).updateNotification(
        'Emergency Activated',
        'Instant Help is active.',
      );
    }
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
    _syncWidgetState();
  }

  Future<void> resolveEmergency() async {
    if (state.activeEmergency != null) {
      AppLogger.info('Emergency state changed: resolved');
      
      // Stop any automatic recording
      await _ref.read(audioCaptureControllerProvider.notifier).stopRecording();
      
      // Reset notification
      _ref.read(hardwareEmergencyTriggerServiceProvider).updateNotification(
        'RAHBAR Protection Active',
        'Emergency protection is running.',
      );

      state = state.copyWith(
        activeEmergency: state.activeEmergency!.copyWith(status: EmergencyStatus.resolved),
      );
      _syncWidgetState();
      // Wait briefly then clear
      Future.delayed(const Duration(seconds: 2), () {
        state = EmergencyState();
      });
    }
  }

  void _syncWidgetState() {
    try {
      final emergencyActive = state.activeEmergency != null && state.activeEmergency!.status != EmergencyStatus.resolved;
      final audioState = _ref.read(audioCaptureControllerProvider);
      
      _ref.read(widgetCommunicationServiceProvider).syncStateToWidgets(
        emergencyActive: emergencyActive,
        audioRecordingActive: audioState.isRecording,
        audioRecordingSource: audioState.activeEvidence?.source.name ?? 'unknown',
      );
    } catch (e) {
      // Ignored if provider not ready
    }
  }
}

final emergencyControllerProvider = StateNotifierProvider<EmergencyController, EmergencyState>((ref) {
  return EmergencyController(ref);
});
