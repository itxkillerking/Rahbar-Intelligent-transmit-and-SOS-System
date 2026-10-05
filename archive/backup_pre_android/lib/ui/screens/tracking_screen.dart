import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../application/telemetry_controller.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final telemetryState = ref.watch(telemetryControllerProvider);
    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;
    final currentStatus = emergencyState.activeEmergency?.status ?? EmergencyStatus.idle;

    String networkText = 'Online - Synced';
    Color networkColor = AppTheme.safeColor;
    if (telemetryState.networkStatus == NetworkStatus.offline) {
      networkText = 'Offline - Caching Locally';
      networkColor = AppTheme.errorColor;
    } else if (telemetryState.networkStatus == NetworkStatus.reconnecting) {
      networkText = 'Reconnecting...';
      networkColor = AppTheme.warningColor;
    } else if (telemetryState.networkStatus == NetworkStatus.syncing) {
      networkText = 'Syncing Prototype Data...';
      networkColor = AppTheme.primaryColor;
    }
    
    final lastUpdateTime = '${telemetryState.lastUpdate.hour.toString().padLeft(2, '0')}:${telemetryState.lastUpdate.minute.toString().padLeft(2, '0')}:${telemetryState.lastUpdate.second.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Live Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spacingMedium),
            child: Center(child: StatusBadge(status: currentStatus)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMapMock(isEmergencyActive),
            const SizedBox(height: AppTheme.spacingLarge),
            const Text('Live Telemetry (Prototype)', style: AppTheme.titleStyle),
            const SizedBox(height: AppTheme.spacingMedium),
            _buildTelemetryCard(
              icon: Icons.location_on_rounded,
              title: 'Current Location',
              value: telemetryState.currentLocation,
              subtitle: 'Last update: $lastUpdateTime',
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.sync_rounded,
                    title: 'Pending Sync',
                    value: '${telemetryState.pendingSyncCount}',
                    subtitle: 'Cached Records',
                    valueColor: telemetryState.pendingSyncCount > 0 ? AppTheme.warningColor : AppTheme.safeColor,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.battery_charging_full_rounded,
                    title: 'Device',
                    value: '78%',
                    subtitle: 'Charging',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            _buildTelemetryCard(
              icon: Icons.security_rounded,
              title: 'Network Status',
              value: networkText,
              subtitle: 'Prototype State',
              valueColor: networkColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMock(bool isActive) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        child: Stack(
          children: [
            // Grid pattern representing map tiles
            GridPaper(
              color: AppTheme.secondaryColor.withValues(alpha: 0.05),
              divisions: 2,
              subdivisions: 2,
              child: Container(width: double.infinity, height: double.infinity),
            ),
            // User Location Marker
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: (isActive ? AppTheme.errorColor : AppTheme.safeColor).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: (isActive ? AppTheme.errorColor : AppTheme.safeColor).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: isActive ? AppTheme.errorColor : AppTheme.safeColor,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                      ],
                    ),
                    child: Text(
                      isActive ? 'Tracking Active' : 'Last Known Location',
                      style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    Color? valueColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.textSecondary, size: 16),
                const SizedBox(width: 8),
                Text(title, style: AppTheme.captionStyle),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTheme.titleStyle.copyWith(color: valueColor ?? AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTheme.captionStyle),
          ],
        ),
      ),
    );
  }
}
