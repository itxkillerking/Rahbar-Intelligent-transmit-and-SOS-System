import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';
import '../widgets/action_card.dart';
import '../widgets/emergency_status_card.dart';
import '../widgets/premium_header.dart';
import '../widgets/status_chip.dart';
import '../../application/telemetry_controller.dart';
import '../../application/evidence_controller.dart';
import '../../domain/models/evidence.dart';
import 'evidence_screen.dart';
import 'video_capture_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final telemetryState = ref.watch(telemetryControllerProvider);
    final audioState = ref.watch(audioCaptureControllerProvider);

    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;
    final currentStatus =
        emergencyState.activeEmergency?.status ?? EmergencyStatus.idle;

    // Bottom padding accounts for the floating nav bar (approx 80px) + some safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom + 100.0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(isEmergencyActive, telemetryState.networkStatus),
            if (telemetryState.networkStatus == NetworkStatus.offline)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMedium,
                    vertical: AppTheme.spacingSmall),
                color: AppTheme.warningColor.withValues(alpha: 0.1),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: AppTheme.warningColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Offline. Prototype emergency data will remain cached locally.',
                        style: AppTheme.captionStyle
                            .copyWith(color: AppTheme.warningColor),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingLarge),
                  EmergencyStatusCard(
                    status: currentStatus,
                    isEmergencyActive: isEmergencyActive,
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),

                  // Core Safety Actions (Always Visible)
                  _buildCoreActions(
                      context, ref, isEmergencyActive, audioState),

                  if (isEmergencyActive) ...[
                    const SizedBox(height: AppTheme.spacingLarge),
                    _buildContextualActions(ref, currentStatus),
                  ],

                  const SizedBox(height: AppTheme.spacingXLarge),

                  // Resources Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Resources', style: AppTheme.titleStyle),
                      Text('Tools to keep you safer',
                          style: AppTheme.captionStyle),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  IntrinsicHeight(
                    child: _buildResourcesGrid(context),
                  ),

                  const SizedBox(height: AppTheme.spacingXLarge),

                  // Recent Activity
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Activity', style: AppTheme.titleStyle),
                      Text('View all >',
                          style: AppTheme.captionStyle
                              .copyWith(color: AppTheme.accentBlue)),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildRecentActivity(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isEmergencyActive, NetworkStatus networkStatus) {
    String netLabel = 'Protected';
    StatusChipType netType = StatusChipType.safe;

    if (isEmergencyActive) {
      netLabel = 'Active';
      netType = StatusChipType.danger;
    } else {
      switch (networkStatus) {
        case NetworkStatus.online:
          netLabel = 'Online';
          break;
        case NetworkStatus.offline:
          netLabel = 'Offline';
          netType = StatusChipType.warning;
          break;
        case NetworkStatus.reconnecting:
          netLabel = 'Reconnecting';
          netType = StatusChipType.warning;
          break;
        case NetworkStatus.syncing:
          netLabel = 'Syncing';
          netType = StatusChipType.warning;
          break;
      }
    }

    return PremiumHeader(
      title: 'Hello, User',
      subtitle: 'Stay safe. Stay connected.\nWe\'re with you, always.',
      trailing: StatusChip(
        label: netLabel,
        type: netType,
        isAnimated: isEmergencyActive,
      ),
    );
  }

  Widget _buildCoreActions(BuildContext context, WidgetRef ref,
      bool isEmergencyActive, AudioCaptureState audioState) {
    return Row(
      children: [
        Expanded(
          child: _buildCoreActionButton(
            icon: audioState.isRecording
                ? Icons.mic_rounded
                : Icons.volume_up_rounded,
            label: audioState.isRecording ? 'Recording' : 'Audio',
            subtitle: audioState.isRecording
                ? 'Capturing audio...'
                : 'Share live audio',
            color: audioState.isRecording
                ? AppTheme.errorColor
                : AppTheme.accentBlue,
            // Always allow manual audio recording, even if emergency is not active, for evidence gathering.
            isActive: true,
            onTap: () async {
              if (audioState.isRecording) {
                await ref
                    .read(audioCaptureControllerProvider.notifier)
                    .stopRecording();
              } else {
                final granted = await ref
                    .read(audioCaptureControllerProvider.notifier)
                    .requestPermission();
                if (granted) {
                  await ref
                      .read(audioCaptureControllerProvider.notifier)
                      .startRecording(EvidenceSource.manualAudio);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Microphone permission is required to record audio.')),
                    );
                  }
                }
              }
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        _buildMainEmergencyButton(ref, isEmergencyActive),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: _buildCoreActionButton(
            icon: Icons.videocam_rounded,
            label: 'Video',
            subtitle: 'Share live video',
            color: AppTheme.accentBlue,
            isActive: true,
            onTap: () async {
              final status = await Permission.camera.request();
              if (!context.mounted) return;
              if (status.isGranted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const VideoCaptureScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Camera permission is required.')),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainEmergencyButton(WidgetRef ref, bool isEmergencyActive) {
    return _SOSButton(isEmergencyActive: isEmergencyActive, ref: ref);
  }

  Widget _buildCoreActionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final effectiveColor = isActive ? color : AppTheme.textSecondary;
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
          boxShadow: AppTheme.premiumShadow,
          border: Border.all(
              color: isActive
                  ? effectiveColor.withValues(alpha: 0.2)
                  : Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: effectiveColor, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: effectiveColor)),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTheme.captionStyle.copyWith(fontSize: 9),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
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
              label: 'I NEED HELP\nConfirm Emergency',
              color: AppTheme.errorColor,
              onTap: () => ref
                  .read(emergencyControllerProvider.notifier)
                  .confirmNormalEmergency(),
            ),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: _buildActionButton(
              icon: Icons.cancel_rounded,
              label: 'I\'M SAFE\nCancel Alert',
              color: AppTheme.safeColor,
              onTap: () => ref
                  .read(emergencyControllerProvider.notifier)
                  .cancelNormalEmergency(),
            ),
          ),
        ],
      );
    } else if (status == EmergencyStatus.sent ||
        status == EmergencyStatus.offlinePending) {
      return _buildActionButton(
        icon: Icons.shield_rounded,
        label: 'Resolve\nMark as resolved',
        color: AppTheme.accentBlue,
        onTap: () =>
            ref.read(emergencyControllerProvider.notifier).resolveEmergency(),
      );
    }
    return const SizedBox.shrink();
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
                Text(parts[0],
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                if (parts.length > 1)
                  Text(parts[1], style: TextStyle(color: color, fontSize: 11)),
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
            onTap: () {
              // Will navigate via shell index eventually or direct push
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacingMedium),
        Expanded(
          child: ActionCard(
            title: 'Evidence',
            subtitle: 'Record securely',
            icon: Icons.camera_alt_rounded,
            iconColor: AppTheme.accentBlue,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EvidenceScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.spacingMedium,
                AppTheme.spacingMedium, AppTheme.spacingMedium, 0),
            child: Text(
              'Prototype Demonstration Records',
              style: AppTheme.captionStyle.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  fontStyle: FontStyle.italic),
            ),
          ),
          _buildActivityRow(
            icon: Icons.notifications_active_rounded,
            title: 'Emergency alert ready',
            subtitle: 'System is monitoring',
            time: 'Active',
            statusColor: AppTheme.safeColor,
          ),
          const Divider(height: 1),
          _buildActivityRow(
            icon: Icons.location_on_rounded,
            title: 'Location sharing active',
            subtitle: 'Live location is ready',
            time: 'Live',
            statusColor: AppTheme.safeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 20),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTheme.bodyStyle
                        .copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTheme.captionStyle),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
            ),
            child: Text(
              time,
              style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SOSButton extends StatefulWidget {
  final bool isEmergencyActive;
  final WidgetRef ref;

  const _SOSButton(
      {Key? key, required this.isEmergencyActive, required this.ref})
      : super(key: key);

  @override
  State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isActiveOrAwaiting = widget.isEmergencyActive;

    return GestureDetector(
      onTapDown: (_) {
        if (!isActiveOrAwaiting) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!isActiveOrAwaiting) {
          setState(() => _isPressed = false);
          widget.ref
              .read(emergencyControllerProvider.notifier)
              .startNormalEmergency();
        }
      },
      onTapCancel: () {
        if (!isActiveOrAwaiting) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            shape: BoxShape.circle,
            boxShadow: isActiveOrAwaiting
                ? AppTheme.glowShadowRed
                : [
                    BoxShadow(
                      color: AppTheme.errorColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('SOS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text('TRIGGER SOS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
              const SizedBox(height: 12),
              Text(
                'Emergency',
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
