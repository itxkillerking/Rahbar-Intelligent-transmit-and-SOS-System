import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/models/evidence.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Evidence evidence;

  const AudioPlayerScreen({Key? key, required this.evidence}) : super(key: key);

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setFilePath(widget.evidence.filePath);
      _player.durationStream.listen((d) {
        if (mounted && d != null) setState(() => _duration = d);
      });
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((state) {
        if (mounted) setState(() => _isPlaying = state.playing);
        if (state.processingState == ProcessingState.completed) {
          _player.seek(Duration.zero);
          _player.pause();
        }
      });
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Audio Evidence'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic_rounded, size: 80, color: AppTheme.safeColor),
            const SizedBox(height: AppTheme.spacingXLarge),
            Text('Local Evidence', style: AppTheme.titleStyle),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(widget.evidence.filePath.split('/').last, style: AppTheme.captionStyle, textAlign: TextAlign.center),
            const SizedBox(height: 60),
            Slider(
              activeColor: AppTheme.primaryColor,
              inactiveColor: AppTheme.textSecondary.withValues(alpha: 0.2),
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
              onChanged: (v) {
                _player.seek(Duration(milliseconds: v.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position), style: AppTheme.captionStyle),
                  Text(_formatDuration(_duration), style: AppTheme.captionStyle),
                ],
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                if (_isPlaying) {
                  _player.pause();
                } else {
                  _player.play();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor,
                  boxShadow: AppTheme.premiumShadow,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
