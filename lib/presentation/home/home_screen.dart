import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../application/emergency_controller.dart';
import '../../domain/models/emergency_status.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/widgets/action_card.dart';
import 'package:rahbar/presentation/emergency/emergency_status_card.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/widgets/status_chip.dart';
import '../../application/telemetry_controller.dart';
import '../../application/evidence_controller.dart';
import '../../domain/models/evidence.dart';
import 'package:rahbar/presentation/evidence/evidence_screen.dart';
import 'package:rahbar/presentation/evidence/video_capture_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/presentation/profile/complete_profile_screen.dart';
import 'package:rahbar/presentation/profile/profile_screen.dart';
import 'package:rahbar/presentation/shared/components/rahbar_drawer.dart';
import 'package:rahbar/application/locale_controller.dart';
import 'package:rahbar/presentation/shared/components/rahbar_drawer.dart';
import 'package:rahbar/application/profile/local_avatar_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
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
                  _buildProfileReminder(context, ref),
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
    final isUrdu = ref.watch(localeProvider);
    String netLabel = AppStrings.get(isUrdu, 'safety_network_ready');
    StatusChipType netType = StatusChipType.safe;

    if (isEmergencyActive) {
      netLabel = AppStrings.get(isUrdu, 'system_active');
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

    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    final firstName = profile?.fullName?.split(' ').first ?? 'User';

    return PremiumHeader(
      title: 'Hello, $firstName',
      subtitle: AppStrings.get(isUrdu, 'app_subtitle'),
      showProfileMenu: true,
      trailing: StatusChip(
        label: netLabel,
        type: netType,
        isAnimated: isEmergencyActive,
      ),
    );
  }



  Widget _buildProfileReminder(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;
    final isUrdu = ref.watch(localeProvider);

    if (profile == null) return const SizedBox.shrink();

    final percentage = profile.completionPercentage;
    if (percentage >= 100) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
          boxShadow: AppTheme.premiumShadow,
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: CircularProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.1),
                    color: AppTheme.primaryColor,
                    strokeWidth: 4,
                  ),
                ),
                Text('$percentage%', style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 10)),
              ],
            ),
            const SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.get(isUrdu, 'complete_profile'), style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('${100 - percentage}% remaining', style: AppTheme.captionStyle),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (profile.profileCompleted == true) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CompleteProfileScreen()));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                minimumSize: const Size(0, 36),
                elevation: 0,
              ),
              child: const Text('Complete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoreActions(BuildContext context, WidgetRef ref,
      bool isEmergencyActive, AudioCaptureState audioState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Safely fallback if constraints are unbounded or zero during layout pass
        double availableWidth = constraints.maxWidth;
        if (!availableWidth.isFinite || availableWidth <= 0) {
          availableWidth = MediaQuery.sizeOf(context).width - 48.0; // screen width minus horizontal padding
        }
        if (availableWidth < 200.0) availableWidth = 200.0; // extreme fallback

        const double gap = 12.0;
        
        // Assign roughly 26% of available width to side cards, bounded safely.
        final double sideCardWidth = (availableWidth * 0.26).clamp(80.0, 115.0);
        
        // SOS gets the remaining width to ensure a perfect fit without overflow.
        // Clamp to prevent negative or infinite sizes.
        final double calculatedSos = availableWidth - (sideCardWidth * 2) - (gap * 2);
        final double sosSize = calculatedSos.clamp(100.0, 200.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: sideCardWidth,
              child: _buildCoreActionButton(
                icon: audioState.isRecording
                    ? Icons.mic_rounded
                    : Icons.volume_up_rounded,
                label: audioState.isRecording ? 'Recording' : 'Audio',
                subtitle: audioState.isRecording
                    ? 'Capturing\naudio'
                    : 'Share live\naudio',
                color: audioState.isRecording
                    ? AppTheme.errorColor
                    : Colors.blueAccent.shade700,
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
            const SizedBox(width: gap),
            SizedBox(
              width: sosSize,
              height: sosSize, // Ensure SOS is a perfect square bounding box
              child: _buildMainEmergencyButton(ref, isEmergencyActive),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: sideCardWidth,
              child: _buildCoreActionButton(
                icon: Icons.videocam_rounded,
                label: 'Video',
                subtitle: 'Share live\nvideo',
                color: Colors.deepPurpleAccent,
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
      },
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white, // Clean white base
          borderRadius: BorderRadius.circular(32), // Softer, broader rounded corners
          boxShadow: [
            BoxShadow(
              color: effectiveColor.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
              color: isActive
                  ? effectiveColor.withValues(alpha: 0.05)
                  : Colors.transparent,
              width: 1.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor, size: 32),
            const SizedBox(height: 8),
            Text(label,
                style: AppTheme.bodyStyle.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.captionStyle.copyWith(
                  fontSize: 11,
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  height: 1.1),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: effectiveColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.chevron_right_rounded,
                  size: 16, color: effectiveColor),
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
  DateTime? _lastTapDownTime;

  void _handleTapDown() {
    if (!widget.isEmergencyActive) {
      _lastTapDownTime = DateTime.now();
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp() {
    if (!widget.isEmergencyActive) {
      // 1. Invoke EXISTING SOS callback immediately!
      widget.ref.read(emergencyControllerProvider.notifier).startNormalEmergency();
      
      // 2. Ensure minimum visual feedback duration for a quick tap.
      _revertPressState();
    }
  }

  void _handleTapCancel() {
    if (!widget.isEmergencyActive) {
      _revertPressState();
    }
  }

  void _revertPressState() {
    if (_lastTapDownTime == null) {
      setState(() => _isPressed = false);
      return;
    }
    
    final elapsed = DateTime.now().difference(_lastTapDownTime!);
    const minVisualDuration = Duration(milliseconds: 100); // Guarantees a visible pulse
    
    if (elapsed < minVisualDuration) {
      final remaining = minVisualDuration - elapsed;
      Future.delayed(remaining, () {
        if (mounted) setState(() => _isPressed = false);
      });
    } else {
      setState(() => _isPressed = false);
    }
    _lastTapDownTime = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isActiveOrAwaiting = widget.isEmergencyActive;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Rely entirely on the explicitly provided tight bounds from the parent,
        // but safely fallback if unbounded or zero.
        double responsiveSize = constraints.maxWidth;
        if (!responsiveSize.isFinite || responsiveSize <= 0) {
          responsiveSize = 140.0;
        }
        
        final double innerRingSize = responsiveSize * 0.85;
        final double coreSize = responsiveSize * 0.72;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _handleTapDown(),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: AnimatedScale(
            scale: _isPressed ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: responsiveSize,
              height: responsiveSize,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow & Thin Ring
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: responsiveSize,
                    height: responsiveSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.errorColor.withValues(alpha: _isPressed ? 0.4 : 0.1),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorColor.withValues(alpha: _isPressed ? 0.35 : 0.15),
                          blurRadius: 40,
                          spreadRadius: _isPressed ? 12 : 10,
                        ),
                      ],
                    ),
                  ),
                  // Inner Gap Ring
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: innerRingSize,
                    height: innerRingSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.errorColor.withValues(alpha: _isPressed ? 0.5 : 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Main Glossy Button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    width: coreSize,
                    height: coreSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF6B6B), // Bright red highlight for spherical feel
                          AppTheme.errorColor,
                          const Color(0xFFC62828), // Darker red at bottom edge
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        center: const Alignment(0, -0.4),
                        radius: 1.1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.errorColor.withValues(alpha: 0.6),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    // Removed the harsh white glass overlay entirely, relying on gradient for 3D
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_active_rounded, // Premium siren/alert icon
                            color: Colors.white,
                            size: coreSize * 0.28,
                          ),
                          const SizedBox(height: 4),
                          Text('SOS',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: coreSize * 0.26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  height: 1.0)),
                          const SizedBox(height: 2),
                          Text(isActiveOrAwaiting ? 'ACTIVE' : 'EMERGENCY',
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontSize: coreSize * 0.10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
