import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../domain/models/evidence.dart';
import '../domain/models/emergency_status.dart';
import '../core/logging/app_logger.dart';
import 'evidence_repository.dart';
import 'emergency_controller.dart';
import 'package:rahbar/services/widgets/widget_communication_service.dart';

final evidenceControllerProvider =
    StateNotifierProvider<EvidenceController, List<Evidence>>((ref) {
  final repo = ref.read(evidenceRepositoryProvider);
  final controller = EvidenceController(repo);
  controller.loadEvidence();
  return controller;
});

class EvidenceController extends StateNotifier<List<Evidence>> {
  final EvidenceRepository _repo;

  EvidenceController(this._repo) : super([]);

  Future<void> loadEvidence() async {
    final list = await _repo.getAllEvidence();
    state = list;
  }

  Future<void> updateEvidence(Evidence evidence) async {
    await _repo.saveEvidence(evidence);
    await loadEvidence();
  }
}

// Active audio capture controller
final audioCaptureControllerProvider =
    StateNotifierProvider<AudioCaptureController, AudioCaptureState>((ref) {
  return AudioCaptureController(ref);
});

class AudioCaptureState {
  final bool isRecording;
  final Evidence? activeEvidence;

  AudioCaptureState({this.isRecording = false, this.activeEvidence});
}

class AudioCaptureController extends StateNotifier<AudioCaptureState> {
  final Ref _ref;
  final _audioRecorder = AudioRecorder();
  DateTime? _startTime;

  AudioCaptureController(this._ref) : super(AudioCaptureState());

  Future<String> _getFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final evidenceDir = Directory('${dir.path}/evidence/audio');
    if (!await evidenceDir.exists()) {
      await evidenceDir.create(recursive: true);
    }
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return '${evidenceDir.path}/rahbar_audio_$timestamp.m4a';
  }

  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> startRecording(EvidenceSource source,
      {String? emergencyId}) async {
    if (state.isRecording) return false;

    try {
      if (await _audioRecorder.hasPermission()) {
        final path = await _getFilePath();

        final evidence = Evidence.create(
          type: EvidenceType.audio,
          filePath: path,
          source: source,
          emergencyId: emergencyId,
        );

        // Save initial recording state
        await _ref
            .read(evidenceControllerProvider.notifier)
            .updateEvidence(evidence);

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        _startTime = DateTime.now();
        state = AudioCaptureState(isRecording: true, activeEvidence: evidence);
        _syncWidgetState();
        AppLogger.info('Audio recording started: $path');
        return true;
      } else {
        AppLogger.warning('Microphone permission denied.');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to start audio recording', e);
      return false;
    }
  }

  Future<void> stopRecording() async {
    if (!state.isRecording || state.activeEvidence == null) return;

    try {
      final path = await _audioRecorder.stop();
      if (path != null && _startTime != null) {
        final duration = DateTime.now().difference(_startTime!).inSeconds;
        final file = File(path);
        final size = await file.length();

        final finalizedEvidence = state.activeEvidence!.copyWith(
          durationSeconds: duration,
          fileSize: size,
          status: EvidenceStatus.savedLocally,
        );

        await _ref
            .read(evidenceControllerProvider.notifier)
            .updateEvidence(finalizedEvidence);
        AppLogger.info('Audio recording stopped and saved: $path');
      }
    } catch (e) {
      AppLogger.error('Failed to stop audio recording', e);
    } finally {
      state = AudioCaptureState(isRecording: false);
      _startTime = null;
      _syncWidgetState();
    }
  }

  void _syncWidgetState() {
    try {
      final emergencyActive =
          _ref.read(emergencyControllerProvider).activeEmergency != null &&
              _ref.read(emergencyControllerProvider).activeEmergency!.status !=
                  EmergencyStatus.resolved;

      _ref.read(widgetCommunicationServiceProvider).syncStateToWidgets(
            emergencyActive: emergencyActive,
            audioRecordingActive: state.isRecording,
            audioRecordingSource:
                state.activeEvidence?.source.name ?? 'unknown',
          );
    } catch (e) {
      // Ignored if provider not ready
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}
