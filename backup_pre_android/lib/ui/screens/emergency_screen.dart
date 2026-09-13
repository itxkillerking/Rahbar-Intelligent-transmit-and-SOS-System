import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_tile.dart';
import '../widgets/status_badge.dart';
import 'evidence_screen.dart';
import 'tracking_screen.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  bool _isRecordingAudio = false;
  bool _isRecordingVideo = false;

  @override
  Widget build(BuildContext context) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;
    final currentStatus = emergencyState.activeEmergency?.status ?? EmergencyStatus.idle;

    // Auto-reset mock recording if emergency ends
    if (!isEmergencyActive && (_isRecordingAudio || _isRecordingVideo)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isRecordingAudio = false;
            _isRecordingVideo = false;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Emergency Management', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Status Card
            _buildStatusCard(isEmergencyActive, currentStatus),
            const SizedBox(height: AppTheme.spacingLarge),

            // 2. Evidence Controls Row
            const Text('Emergency Controls', style: AppTheme.titleStyle),
            const SizedBox(height: AppTheme.spacingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildMockMediaControl(
                  icon: Icons.mic_rounded,
                  label: 'Audio',
                  isRecording: _isRecordingAudio,
                  isEnabled: isEmergencyActive,
                  onToggle: () => setState(() => _isRecordingAudio = !_isRecordingAudio),
                ),
                _buildCenterEmergencyAction(isEmergencyActive, currentStatus),
                _buildMockMediaControl(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  isRecording: _isRecordingVideo,
                  isEnabled: isEmergencyActive,
                  onToggle: () => setState(() => _isRecordingVideo = !_isRecordingVideo),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // 3. Tracking & Evidence Vault
            const Text('Resources', style: AppTheme.titleStyle),
            const SizedBox(height: AppTheme.spacingMedium),
            DashboardTile(
              title: 'Live Tracking',
              subtitle: 'View active telemetry and location',
              icon: Icons.location_on_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen())),
            ),
            DashboardTile(
              title: 'Evidence Vault',
              subtitle: 'Review collected audio and video',
              icon: Icons.folder_special_rounded,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceScreen())),
            ),
            const SizedBox(height: AppTheme.spacingLarge),

            // 4. Emergency History (Mock)
            const Text('Recent History (Prototype Data)', style: AppTheme.titleStyle),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildMockHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isActive, EmergencyStatus status) {
    if (!isActive) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLarge),
          child: Column(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: AppTheme.safeColor, size: 48),
              const SizedBox(height: AppTheme.spacingMedium),
              const Text('No Active Emergency', style: AppTheme.headingStyle),
              const SizedBox(height: AppTheme.spacingSmall),
              const Text(
                'Your status is currently safe. SOS activation is available from the Home screen.',
                textAlign: TextAlign.center,
                style: AppTheme.bodyStyle,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: AppTheme.errorColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        side: BorderSide(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            StatusBadge(status: status),
            const SizedBox(height: AppTheme.spacingMedium),
            Text('EMERGENCY ACTIVE', style: AppTheme.headingStyle.copyWith(color: AppTheme.errorColor)),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildEmergencyActionButtons(status),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyActionButtons(EmergencyStatus status) {
    if (status == EmergencyStatus.awaitingConfirmation) {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => ref.read(emergencyControllerProvider.notifier).confirmNormalEmergency(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
              child: const Text('CONFIRM'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: OutlinedButton(
              onPressed: () => ref.read(emergencyControllerProvider.notifier).cancelNormalEmergency(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.textSecondary),
              ),
              child: const Text('CANCEL', style: TextStyle(color: AppTheme.textSecondary)),
            ),
          ),
        ],
      );
    }
    if (status == EmergencyStatus.sent || status == EmergencyStatus.offlinePending) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => ref.read(emergencyControllerProvider.notifier).resolveEmergency(),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safeColor),
          child: const Text('RESOLVE EMERGENCY'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMockMediaControl({
    required IconData icon,
    required String label,
    required bool isRecording,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    final color = isEnabled
        ? (isRecording ? AppTheme.errorColor : AppTheme.secondaryColor)
        : AppTheme.textSecondary.withValues(alpha: 0.3);

    return Column(
      children: [
        InkWell(
          onTap: isEnabled ? onToggle : null,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: Icon(isRecording ? Icons.stop_rounded : icon, color: color, size: 32),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          isRecording ? 'Recording...' : label,
          style: AppTheme.captionStyle.copyWith(
            color: isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontWeight: isRecording ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterEmergencyAction(bool isActive, EmergencyStatus status) {
    return InkWell(
      onTap: () {
        if (!isActive) {
          ref.read(emergencyControllerProvider.notifier).startNormalEmergency();
        }
      },
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXLarge),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.warningColor : AppTheme.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppTheme.warningColor : AppTheme.primaryColor).withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: const Icon(
          Icons.warning_rounded,
          color: Colors.white,
          size: 48,
        ),
      ),
    );
  }

  Widget _buildMockHistoryList() {
    return Column(
      children: [
        _buildMockHistoryTile('Normal SOS', 'Oct 12, 2026 - 14:30', 'Resolved'),
        _buildMockHistoryTile('Silent Danger', 'Sep 28, 2026 - 09:15', 'Resolved'),
        _buildMockHistoryTile('Normal SOS', 'Aug 05, 2026 - 22:10', 'Resolved'),
      ],
    );
  }

  Widget _buildMockHistoryTile(String title, String subtitle, String statusLabel) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
      ),
      child: ListTile(
        leading: const Icon(Icons.history_rounded, color: AppTheme.textSecondary),
        title: Text(title, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTheme.captionStyle),
        trailing: Text(statusLabel, style: AppTheme.captionStyle.copyWith(color: AppTheme.safeColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
