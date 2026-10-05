import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/emergency_controller.dart';
import '../../application/telemetry_controller.dart';
import '../../domain/models/emergency_status.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/widgets/status_chip.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyState = ref.watch(emergencyControllerProvider);
    final telemetryState = ref.watch(telemetryControllerProvider);
    
    final isEmergencyActive = emergencyState.activeEmergency != null &&
        emergencyState.activeEmergency!.status != EmergencyStatus.resolved;

    String networkText = 'Online - Synced';
    Color networkColor = AppTheme.safeColor;

    if (telemetryState.networkStatus == NetworkStatus.offline) {
      networkText = 'Cached Locally';
      networkColor = AppTheme.errorColor;
    } else if (telemetryState.networkStatus == NetworkStatus.reconnecting) {
      networkText = 'Reconnecting...';
      networkColor = AppTheme.warningColor;
    } else if (telemetryState.networkStatus == NetworkStatus.syncing) {
      networkText = 'Syncing Prototype Data...';
      networkColor = AppTheme.primaryColor;
    }
    
    final lastUpdateTime = '${telemetryState.lastUpdate.hour.toString().padLeft(2, '0')}:${telemetryState.lastUpdate.minute.toString().padLeft(2, '0')}:${telemetryState.lastUpdate.second.toString().padLeft(2, '0')}';
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
              title: 'Live Tracking',
              subtitle: 'Real-time telemetry and location',
              trailing: StatusChip(
                label: isEmergencyActive ? 'Active' : 'Standby',
                type: isEmergencyActive ? StatusChipType.danger : StatusChipType.neutral,
                isAnimated: isEmergencyActive,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingLarge),
                  _buildMapMock(isEmergencyActive),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  
                  const Text('Live Telemetry', style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  _buildTelemetryCard(
                    icon: Icons.location_on_rounded,
                    title: 'Current Location',
                    value: telemetryState.currentLocation,
                    subtitle: 'Last update: $lastUpdateTime',
                    iconColor: AppTheme.accentBlue,
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryCard(
                          icon: Icons.sync_rounded,
                          title: 'Pending Sync',
                          value: '${telemetryState.pendingSyncCount}',
                          subtitle: 'Cached Records',
                          valueColor: telemetryState.pendingSyncCount > 0 ? AppTheme.warningColor : AppTheme.textPrimary,
                          iconColor: telemetryState.pendingSyncCount > 0 ? AppTheme.warningColor : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: _buildTelemetryCard(
                          icon: Icons.battery_charging_full_rounded,
                          title: 'Device',
                          value: '78%',
                          subtitle: 'Charging',
                          iconColor: AppTheme.safeColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  _buildTelemetryCard(
                    icon: Icons.security_rounded,
                    title: 'Network Status',
                    value: networkText,
                    subtitle: 'Prototype State',
                    valueColor: networkColor,
                    iconColor: networkColor,
                  ),
                  const SizedBox(height: AppTheme.spacingXLarge),
                  const Text('Telemetry', style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTelemetryCard(
                          icon: Icons.speed_rounded,
                          title: 'Speed',
                          value: '0 km/h',
                          subtitle: 'Live',
                          iconColor: AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: _buildTelemetryCard(
                          icon: Icons.terrain_rounded,
                          title: 'Altitude',
                          value: '540 m',
                          subtitle: 'Live',
                          iconColor: AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMedium),
                      Expanded(
                        child: _buildTelemetryCard(
                          icon: Icons.satellite_alt_rounded,
                          title: 'GPS',
                          value: '10 m',
                          subtitle: 'Accuracy',
                          iconColor: AppTheme.safeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapMock(bool isActive) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        boxShadow: AppTheme.premiumShadow,
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
              child: const SizedBox(width: double.infinity, height: double.infinity),
            ),
            // User Location Marker
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: (isActive ? AppTheme.primaryColor : AppTheme.safeColor).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: (isActive ? AppTheme.primaryColor : AppTheme.safeColor).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.my_location_rounded,
                        color: isActive ? AppTheme.primaryColor : AppTheme.safeColor,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
                      boxShadow: AppTheme.premiumShadow,
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
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Text(
                  title, 
                  style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),
          Text(
            value, 
            style: AppTheme.titleStyle.copyWith(color: valueColor ?? AppTheme.textPrimary, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle, 
            style: AppTheme.captionStyle.copyWith(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
