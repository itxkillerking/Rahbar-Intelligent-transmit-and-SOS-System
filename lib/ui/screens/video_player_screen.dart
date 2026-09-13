import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

import '../../domain/models/evidence.dart';
import '../theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Evidence evidence;

  const VideoPlayerScreen({Key? key, required this.evidence}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }
  
  Future<void> _initPlayer() async {
    final file = File(widget.evidence.filePath);
    if (!await file.exists()) {
      if (mounted) setState(() => _hasError = true);
      return;
    }
    
    _controller = VideoPlayerController.file(file);
    try {
      await _controller!.initialize();
      _controller!.addListener(_onPlayerUpdate);
      if (mounted) {
        setState(() => _isInitialized = true);
        _controller!.play();
      }
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _onPlayerUpdate() {
    if (!mounted) return;
    setState(() {}); // Rebuild to update progress bar and icons
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppTheme.secondaryColor, size: 20),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(
              'Video Evidence',
              style: AppTheme.titleStyle.copyWith(fontSize: 18),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: _buildVideoContainer(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
              child: _buildMetadataCard(),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: _hasError 
          ? _buildErrorState()
          : !_isInitialized
              ? _buildLoadingState()
              : _buildPlayer(),
    );
  }
  
  Widget _buildErrorState() {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
          SizedBox(height: 16),
          Text('Video unavailable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('The local evidence file could not be opened.', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const AspectRatio(
      aspectRatio: 16 / 9,
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildPlayer() {
    final bool isFinished = _controller!.value.position >= _controller!.value.duration && _controller!.value.duration > Duration.zero;
    final bool isPlaying = _controller!.value.isPlaying;
    
    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller!),
          
          // Play/Pause Overlay
          Center(
            child: GestureDetector(
              onTap: () {
                if (isFinished) {
                  _controller!.seekTo(Duration.zero);
                  _controller!.play();
                } else if (isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              },
              child: AnimatedOpacity(
                opacity: (isPlaying && !isFinished) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFinished ? Icons.replay_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
          
          // Transparent touch layer for pause/play toggle
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (isFinished) {
                  _controller!.seekTo(Duration.zero);
                  _controller!.play();
                } else if (isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              },
            ),
          ),
          
          // Bottom Controls Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _formatDuration(_controller!.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      colors: const VideoProgressColors(
                        playedColor: AppTheme.primaryColor,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetadataCard() {
    final sizeMb = (widget.evidence.fileSize / (1024 * 1024)).toStringAsFixed(2);
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Information', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.safeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppTheme.safeColor, size: 12),
                    const SizedBox(width: 4),
                    Text('Saved Locally', style: AppTheme.captionStyle.copyWith(color: AppTheme.safeColor, fontWeight: FontWeight.w600, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildInfoRow(
            Icons.calendar_today_rounded,
            'Recorded',
            DateFormat('dd MMM yyyy • h:mm a').format(widget.evidence.createdAt),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(),
          ),
          _buildInfoRow(
            Icons.timer_rounded,
            'Duration',
            _formatDuration(Duration(seconds: widget.evidence.durationSeconds)),
          ),
          if (widget.evidence.fileSize > 0) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(),
            ),
            _buildInfoRow(
              Icons.sd_storage_rounded,
              'File Size',
              '$sizeMb MB',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.accentBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.accentBlue, size: 16),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.captionStyle),
            const SizedBox(height: 2),
            Text(value, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }
}
