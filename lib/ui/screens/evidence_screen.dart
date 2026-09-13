import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/emergency_controller.dart';
import '../../application/evidence_controller.dart';
import '../../domain/models/emergency_status.dart';
import '../../domain/models/evidence.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_header.dart';
import '../widgets/status_chip.dart';
import 'audio_player_screen.dart';
import 'video_player_screen.dart';



class EvidenceScreen extends ConsumerStatefulWidget {
  const EvidenceScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends ConsumerState<EvidenceScreen> {


  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;

    final bottomPadding = MediaQuery.of(context).padding.bottom + 100.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PremiumHeader(
              title: 'Evidence',
              subtitle: 'Prototype Evidence Vault',
              trailing: StatusChip(
                label: isEmergencyActive ? 'Recording' : 'Vault Locked',
                type: isEmergencyActive ? StatusChipType.danger : StatusChipType.safe,
                isAnimated: isEmergencyActive,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingLarge),
                  if (isEmergencyActive) ...[
                    _buildActiveCaptureBanner(),
                    const SizedBox(height: AppTheme.spacingLarge),
                  ],
                  
                  _buildEvidenceSections(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidenceSections() {
    final evidenceList = ref.watch(evidenceControllerProvider);

    final audioEvidence = evidenceList.where((e) => e.type == EvidenceType.audio).toList();
    final videoEvidence = evidenceList.where((e) => e.type == EvidenceType.video).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Audio Evidence', style: AppTheme.titleStyle),
        const SizedBox(height: AppTheme.spacingMedium),
        if (audioEvidence.isEmpty)
          _buildEmptyState('No audio evidence saved yet.')
        else
          ...audioEvidence.map((e) => _buildEvidenceItem(e, Icons.mic_rounded, 'Audio Evidence', AppTheme.safeColor)),
          
        const SizedBox(height: AppTheme.spacingXLarge),
        
        const Text('Video Evidence', style: AppTheme.titleStyle),
        const SizedBox(height: AppTheme.spacingMedium),
        if (videoEvidence.isEmpty)
          _buildEmptyState('No video evidence saved yet.')
        else
          ...videoEvidence.map((e) => _buildEvidenceItem(e, Icons.videocam_rounded, 'Video Evidence', AppTheme.secondaryColor)),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Text(
          message,
          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
        ),
      ),
    );
  }

  Widget _buildEvidenceItem(Evidence e, IconData icon, String title, Color color) {
    final durationStr = e.status == EvidenceStatus.recording 
        ? 'Recording...' 
        : '${(e.durationSeconds ~/ 60).toString().padLeft(2, '0')}:${(e.durationSeconds % 60).toString().padLeft(2, '0')}';
        
    final statusStr = e.status == EvidenceStatus.recording ? 'Recording' : 'Saved Locally';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: _buildEvidenceCard(
        evidence: e,
        icon: icon,
        title: title,
        timestamp: DateFormat('MMM dd, yyyy - HH:mm').format(e.createdAt),
        duration: durationStr,
        status: statusStr,
        color: color,
      ),
    );
  }

  Widget _buildActiveCaptureBanner() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fiber_manual_record_rounded, color: AppTheme.errorColor),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Active Emergency', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.errorColor)),
                const Text('Mock evidence is currently being captured.', style: AppTheme.captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard({
    required Evidence evidence,
    required IconData icon,
    required String title,
    required String timestamp,
    required String duration,
    required String status,
    required Color color,
  }) {
    // Determine status color based on text
    Color statusColor = AppTheme.textSecondary;
    IconData statusIcon = Icons.save_alt_rounded;
    if (status.contains('Recording')) {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.fiber_manual_record_rounded;
    } else if (status.contains('Saved')) {
      statusColor = AppTheme.safeColor;
      statusIcon = Icons.save_alt_rounded;
    }

    return GestureDetector(
      onTap: () {
        if (evidence.status == EvidenceStatus.recording) return;
        
        if (evidence.type == EvidenceType.audio) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AudioPlayerScreen(evidence: evidence)));
        } else if (evidence.type == EvidenceType.video) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPlayerScreen(evidence: evidence)));
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timestamp, 
                    style: AppTheme.captionStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 12, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(duration, style: AppTheme.captionStyle.copyWith(fontSize: 11)),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          status, 
                          style: AppTheme.captionStyle.copyWith(color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                evidence.status == EvidenceStatus.recording ? Icons.graphic_eq : Icons.play_arrow_rounded, 
                color: AppTheme.textPrimary.withValues(alpha: 0.8), 
                size: 24
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
