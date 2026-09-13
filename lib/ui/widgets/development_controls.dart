import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers.dart';
import '../../data/mocks/mock_platform_trigger_service.dart';
import '../../data/mocks/mock_synchronization_service.dart';
import '../../application/telemetry_controller.dart';
import '../theme/app_theme.dart';

class DevelopmentControls extends ConsumerWidget {
  const DevelopmentControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.build_circle_rounded, color: AppTheme.textSecondary.withValues(alpha: 0.7), size: 20),
              const SizedBox(width: AppTheme.spacingSmall),
              Text('Prototype Control Panel', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Wrap(
            spacing: AppTheme.spacingSmall,
            runSpacing: AppTheme.spacingSmall,
            children: [
              _buildControlAction(
                icon: Icons.warning_rounded,
                label: 'Test Normal SOS',
                color: AppTheme.primaryColor,
                onTap: () {
                  final triggerService = ref.read(platformTriggerServiceProvider) as MockPlatformTriggerService;
                  triggerService.simulateNormalTrigger();
                },
              ),
              _buildControlAction(
                icon: Icons.volume_off_rounded,
                label: 'Test Silent Danger',
                color: AppTheme.errorColor,
                onTap: () {
                  final triggerService = ref.read(platformTriggerServiceProvider) as MockPlatformTriggerService;
                  triggerService.simulateSilentTrigger();
                },
              ),
              _buildControlAction(
                icon: Icons.wifi_off_rounded,
                label: 'Simulate Offline',
                color: AppTheme.textSecondary,
                onTap: () {
                  final syncService = ref.read(synchronizationServiceProvider) as MockSynchronizationService;
                  syncService.setOnlineStatus(false);
                  ref.read(telemetryControllerProvider.notifier).setOffline();
                  _showFeedback(context, 'Offline mode simulated', AppTheme.warningColor);
                },
              ),
              _buildControlAction(
                icon: Icons.wifi_rounded,
                label: 'Simulate Online',
                color: AppTheme.safeColor,
                onTap: () {
                  final syncService = ref.read(synchronizationServiceProvider) as MockSynchronizationService;
                  syncService.setOnlineStatus(true);
                  ref.read(telemetryControllerProvider.notifier).setOnline();
                  _showFeedback(context, 'Connection restored', AppTheme.safeColor);
                },
              ),
              _buildControlAction(
                icon: Icons.add_location_alt_rounded,
                label: 'Add Mock Telemetry',
                color: AppTheme.accentBlue,
                onTap: () {
                  ref.read(telemetryControllerProvider.notifier).addMockTelemetry();
                  _showFeedback(context, 'Mock telemetry added', AppTheme.accentBlue);
                },
              ),
              _buildControlAction(
                icon: Icons.sync_rounded,
                label: 'Simulate Sync',
                color: AppTheme.secondaryColor,
                onTap: () {
                  ref.read(telemetryControllerProvider.notifier).simulateSync();
                  _showFeedback(context, 'Prototype synchronization complete', AppTheme.safeColor);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context, String message, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
