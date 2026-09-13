import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../application/evidence_controller.dart';
import '../../domain/models/evidence.dart';
import '../theme/app_theme.dart';
import '../../core/logging/app_logger.dart';

class VideoCaptureScreen extends ConsumerStatefulWidget {
  const VideoCaptureScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<VideoCaptureScreen> createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends ConsumerState<VideoCaptureScreen> {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isRecording = false;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _controller = CameraController(_cameras.first, ResolutionPreset.medium, enableAudio: true);
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      AppLogger.error('Camera initialization failed', e);
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized || _isRecording) return;
    try {
      final audioState = ref.read(audioCaptureControllerProvider);
      if (audioState.isRecording) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot record video while emergency audio is recording.')),
        );
        return;
      }
      
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _startTime = DateTime.now();
      });
    } catch (e) {
      AppLogger.error('Video recording start failed', e);
    }
  }

  Future<void> _stopRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;
    try {
      final xFile = await _controller!.stopVideoRecording();
      final duration = _startTime != null ? DateTime.now().difference(_startTime!).inSeconds : 0;
      
      setState(() {
        _isRecording = false;
        _startTime = null;
      });

      // Move file to our local evidence directory
      final dir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${dir.path}/evidence/video');
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }
      
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final finalPath = '${evidenceDir.path}/rahbar_video_$timestamp.mp4';
      
      await xFile.saveTo(finalPath);
      
      final savedFile = File(finalPath);
      if (!await savedFile.exists()) {
        throw Exception('Destination file does not exist after saveTo');
      }
      
      final size = await savedFile.length();
      if (size == 0) {
        throw Exception('Destination file is 0 bytes');
      }
      
      AppLogger.info('Video recording stopped and saved: $finalPath');
      
      final evidenceId = const Uuid().v4();
      final evidence = Evidence(
        id: evidenceId,
        type: EvidenceType.video,
        filePath: finalPath,
        createdAt: DateTime.now(),
        durationSeconds: duration,
        source: EvidenceSource.manualVideo,
        fileSize: size,
        status: EvidenceStatus.savedLocally,
      );
      
      await ref.read(evidenceControllerProvider.notifier).updateEvidence(evidence);
      AppLogger.info('Video evidence persisted: $evidenceId');
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Video recording stop failed', e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
              onPressed: () {
                if (!_isRecording) Navigator.of(context).pop();
              },
            ),
          ),
          if (_isRecording)
            Positioned(
              top: 60,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text('REC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isRecording ? _stopRecording : _startRecording,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? AppTheme.errorColor : Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: _isRecording
                      ? const Icon(Icons.stop_rounded, color: Colors.white, size: 40)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
