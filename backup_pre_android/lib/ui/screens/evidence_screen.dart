import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';

class EvidenceScreen extends ConsumerWidget {
  const EvidenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Evidence Vault', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isEmergencyActive) _buildActiveCaptureBanner(),
            if (isEmergencyActive) const SizedBox(height: AppTheme.spacingLarge),
            
            const Text('Secure Media (Prototype)', style: AppTheme.titleStyle),
            const SizedBox(height: AppTheme.spacingMedium),
            
            _buildEvidenceCard(
              icon: Icons.videocam_rounded,
              title: 'Emergency Video Capture',
              timestamp: 'Oct 12, 2026 - 14:35',
              duration: '01:20',
              status: 'Prototype Evidence',
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildEvidenceCard(
              icon: Icons.mic_rounded,
              title: 'Ambient Audio Log',
              timestamp: 'Oct 12, 2026 - 14:32',
              duration: '05:00',
              status: 'Prototype Evidence',
              color: AppTheme.safeColor,
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildEvidenceCard(
              icon: Icons.camera_alt_rounded,
              title: 'Automated Snapshot',
              timestamp: 'Oct 12, 2026 - 14:30',
              duration: 'Image',
              status: 'Prototype Evidence',
              color: AppTheme.warningColor,
            ),
          ],
        ),
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
                const Text('Evidence is currently being securely captured.', style: AppTheme.captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard({
    required IconData icon,
    required String title,
    required String timestamp,
    required String duration,
    required String status,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
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
                  Text(title, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(timestamp, style: AppTheme.captionStyle),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(duration, style: AppTheme.captionStyle),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Icon(Icons.cloud_done_rounded, size: 14, color: AppTheme.safeColor),
                      const SizedBox(width: 4),
                      Text(status, style: AppTheme.captionStyle.copyWith(color: AppTheme.safeColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill_rounded, color: AppTheme.secondaryColor.withValues(alpha: 0.8), size: 36),
          ],
        ),
      ),
    );
  }
}
