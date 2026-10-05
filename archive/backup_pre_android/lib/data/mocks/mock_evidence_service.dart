import '../../domain/services/evidence_service.dart';

class MockEvidenceService implements EvidenceService {
  @override
  Future<String> gatherEvidence() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate recording
    return "mock_audio_video_evidence.mp4";
  }
}
