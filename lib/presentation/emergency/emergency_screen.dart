import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../domain/models/emergency_status.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/widgets/action_card.dart';
import 'package:rahbar/presentation/emergency/emergency_status_card.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/widgets/status_chip.dart';
import 'package:rahbar/presentation/evidence/evidence_screen.dart';
import 'package:rahbar/presentation/tracking/tracking_screen.dart';

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
              title: 'Emergency',
              subtitle: 'Manage your active safety session',
              trailing: StatusChip(
                label: isEmergencyActive ? 'Active' : 'Protected',
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
                  EmergencyStatusCard(
                    status: currentStatus,
                    isEmergencyActive: isEmergencyActive,
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  if (isEmergencyActive) _buildContextualActions(ref, currentStatus),
                  if (isEmergencyActive) const SizedBox(height: AppTheme.spacingLarge),

                  const Text('Media Controls', style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildCoreActions(isEmergencyActive, currentStatus),
                  
                  const SizedBox(height: AppTheme.spacingXLarge),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resources', style: AppTheme.titleStyle),
                      Text('Tools to keep you safer', style: AppTheme.captionStyle),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildResourcesGrid(context),

                  const SizedBox(height: AppTheme.spacingXLarge),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent History', style: AppTheme.titleStyle),
                      Text('Prototype data', style: AppTheme.captionStyle.copyWith(color: AppTheme.textSecondary.withValues(alpha: 0.7), fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildMockHistoryList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoreActions(bool isEmergencyActive, EmergencyStatus status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCoreActionButton(
          icon: Icons.volume_up_rounded,
          label: _isRecordingAudio ? 'Recording...' : 'Audio',
          color: _isRecordingAudio ? AppTheme.errorColor : AppTheme.accentBlue,
          isActive: isEmergencyActive,
          onTap: () => setState(() => _isRecordingAudio = !_isRecordingAudio),
        ),
        _buildMainEmergencyButton(isEmergencyActive),
        _buildCoreActionButton(
          icon: Icons.videocam_rounded,
          label: _isRecordingVideo ? 'Recording...' : 'Video',
          color: _isRecordingVideo ? AppTheme.errorColor : AppTheme.accentBlue,
          isActive: isEmergencyActive,
          onTap: () => setState(() => _isRecordingVideo = !_isRecordingVideo),
        ),
      ],
    );
  }

  Widget _buildMainEmergencyButton(bool isEmergencyActive) {
    return GestureDetector(
      onTap: () {
        if (!isEmergencyActive) {
          ref.read(emergencyControllerProvider.notifier).startNormalEmergency();
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          shape: BoxShape.circle,
          boxShadow: isEmergencyActive ? AppTheme.glowShadowRed : AppTheme.premiumShadow,
          border: Border.all(color: isEmergencyActive ? AppTheme.primaryColor.withValues(alpha: 0.3) : AppTheme.textSecondary.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: isEmergencyActive ? AppTheme.glowShadowRed : null,
              ),
              child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 4),
            Text(
              'Emergency',
              style: AppTheme.captionStyle.copyWith(
                color: isEmergencyActive ? AppTheme.primaryColor : AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoreActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final effectiveColor = isActive ? color : AppTheme.textSecondary;
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        width: 85,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
          boxShadow: AppTheme.premiumShadow,
          border: Border.all(color: isActive ? effectiveColor.withValues(alpha: 0.2) : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: effectiveColor, size: 28),
            const SizedBox(height: 8),
            Text(label, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600, fontSize: 13, color: effectiveColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualActions(WidgetRef ref, EmergencyStatus status) {
    if (status == EmergencyStatus.awaitingConfirmation) {
      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.check_circle_rounded,
              label: 'Confirm\nI\'m safe',
              color: AppTheme.safeColor,
              onTap: () => ref.read(emergencyControllerProvider.notifier).confirmNormalEmergency(),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: _buildActionButton(
              icon: Icons.cancel_rounded,
              label: 'Cancel\nStop alert',
              color: AppTheme.errorColor,
              onTap: () => _showCancelConfirmation(context, ref),
            ),
          ),
        ],
      );
    } else if (status == EmergencyStatus.sent || status == EmergencyStatus.offlinePending) {
      return _buildActionButton(
        icon: Icons.shield_rounded,
        label: 'Resolve\nMark as resolved',
        color: AppTheme.accentBlue,
        onTap: () => _showResolveConfirmation(context, ref),
      );
    }
    return const SizedBox.shrink();
  }

  void _showCancelConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: AppTheme.errorColor),
            const SizedBox(width: 8),
            const Text('Cancel Emergency?', style: AppTheme.titleStyle),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel the SOS alert? This will stop notifying your guardians.',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Go Back', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(emergencyControllerProvider.notifier).cancelNormalEmergency();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
            ),
            child: const Text('Cancel SOS'),
          ),
        ],
      ),
    );
  }

  void _showResolveConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg)),
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppTheme.accentBlue),
            const SizedBox(width: 8),
            const Text('Resolve Emergency?', style: AppTheme.titleStyle),
          ],
        ),
        content: const Text(
          'Are you completely safe? Marking this as resolved will close the active safety session.',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Go Back', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(emergencyControllerProvider.notifier).resolveEmergency();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
            ),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final parts = label.split('\n');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: AppTheme.spacingSmall),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(parts[0], style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
                if (parts.length > 1) Text(parts[1], style: TextStyle(color: color, fontSize: 11)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResourcesGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ActionCard(
            title: 'Live Tracking',
            subtitle: 'Share your real-time location',
            icon: Icons.location_on_rounded,
            iconColor: AppTheme.safeColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackingScreen())),
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: ActionCard(
            title: 'Evidence',
            subtitle: 'Record securely',
            icon: Icons.camera_alt_rounded,
            iconColor: AppTheme.accentBlue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildMockHistoryList() {
    return Column(
      children: [
        _buildMockHistoryTile('Normal SOS', 'Oct 12, 2026 - 14:30', 'Resolved', AppTheme.safeColor),
        _buildMockHistoryTile('Silent Danger', 'Sep 28, 2026 - 09:15', 'Resolved', AppTheme.safeColor),
        _buildMockHistoryTile('Normal SOS', 'Aug 05, 2026 - 22:10', 'Resolved', AppTheme.safeColor),
      ],
    );
  }

  Widget _buildMockHistoryTile(String title, String subtitle, String statusLabel, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.textSecondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
          ),
          child: const Icon(Icons.history_rounded, color: AppTheme.textSecondary),
        ),
        title: Text(title, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: AppTheme.captionStyle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
          ),
          child: Text(
            statusLabel,
            style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
