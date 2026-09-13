import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';
import '../widgets/dashboard_tile.dart';
import '../widgets/sos_button.dart';
import '../widgets/status_badge.dart';
import 'command_center_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;
    final currentStatus = emergencyState.activeEmergency?.status ?? EmergencyStatus.idle;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('RAHBAR', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
            child: Center(child: StatusBadge(status: currentStatus)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Header Info
              const Text('Hello, User', style: AppTheme.headingStyle),
              const SizedBox(height: 4),
              const Text('Your personal safety system is active.', style: AppTheme.captionStyle),
              const SizedBox(height: AppTheme.spacingXLarge),

              // 2. Main SOS Area
              Center(
                child: SosButton(
                  isActive: isEmergencyActive,
                  onPressed: () {
                    if (!isEmergencyActive) {
                      ref.read(emergencyControllerProvider.notifier).startNormalEmergency();
                    }
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingLarge),

              // Emergency Context Actions
              if (isEmergencyActive) _buildEmergencyActions(ref, currentStatus),
              if (!isEmergencyActive) const SizedBox(height: AppTheme.spacingLarge),

              const SizedBox(height: AppTheme.spacingXLarge),

              // 3. Safety/Status Information
              const Text('System Status', style: AppTheme.titleStyle),
              const SizedBox(height: AppTheme.spacingMedium),
              _buildSystemStatus(),

              const SizedBox(height: AppTheme.spacingXLarge),

              // 4. Dashboard Actions
              const Text('Quick Access', style: AppTheme.titleStyle),
              const SizedBox(height: AppTheme.spacingMedium),
              DashboardTile(
                title: 'Command Center',
                subtitle: 'Prototype dispatcher monitoring view',
                icon: Icons.admin_panel_settings_rounded,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommandCenterScreen())),
              ),
              
              const SizedBox(height: AppTheme.spacingXLarge),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyActions(WidgetRef ref, EmergencyStatus status) {
    return Column(
      children: [
        Text(
          'Status: ${status.name.toUpperCase()}',
          style: AppTheme.titleStyle.copyWith(color: AppTheme.errorColor),
        ),
        const SizedBox(height: AppTheme.spacingMedium),
        if (status == EmergencyStatus.awaitingConfirmation) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ref.read(emergencyControllerProvider.notifier).confirmNormalEmergency(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
                  child: const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => ref.read(emergencyControllerProvider.notifier).cancelNormalEmergency(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm)),
                    side: const BorderSide(color: AppTheme.textSecondary),
                  ),
                  child: const Text('CANCEL'),
                ),
              ),
            ],
          ),
        ],
        if (status == EmergencyStatus.sent || status == EmergencyStatus.offlinePending)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => ref.read(emergencyControllerProvider.notifier).resolveEmergency(),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safeColor),
              child: const Text('RESOLVE EMERGENCY', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
      ],
    );
  }

  Widget _buildSystemStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          children: [
            _statusRow(Icons.wifi_rounded, 'Network', 'Online / Synced', AppTheme.safeColor),
            const Divider(height: AppTheme.spacingLarge),
            _statusRow(Icons.gps_fixed_rounded, 'Location', 'Tracking Active', AppTheme.safeColor),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(IconData icon, String label, String value, Color statusColor) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: AppTheme.spacingMedium),
        Text(label, style: AppTheme.bodyStyle),
        const Spacer(),
        Text(
          value,
          style: AppTheme.bodyStyle.copyWith(color: statusColor, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
