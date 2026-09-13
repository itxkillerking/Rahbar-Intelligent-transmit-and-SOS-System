import 'package:flutter/material.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';
import 'status_formatter.dart';

class EmergencyStatusCard extends StatelessWidget {
  final EmergencyStatus status;
  final VoidCallback? onToggle; // To activate/deactivate emergency directly
  final bool isEmergencyActive;

  const EmergencyStatusCard({
    Key? key,
    required this.status,
    required this.isEmergencyActive,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isEmergencyActive) {
      return _buildIdleCard();
    }
    return _buildActiveCard();
  }

  Widget _buildIdleCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightGreenSurface,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        border: Border.all(color: AppTheme.brightGreenAccent.withValues(alpha: 0.2)),
        boxShadow: AppTheme.premiumShadow,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: AppTheme.brightGreenAccent, size: 32),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You are Protected', style: AppTheme.titleStyle.copyWith(color: AppTheme.secondaryColor)),
                const SizedBox(height: 2),
                Text('All systems active and monitoring', style: AppTheme.captionStyle.copyWith(color: AppTheme.secondaryColor.withValues(alpha: 0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCard() {
    bool isAwaiting = status == EmergencyStatus.awaitingConfirmation;
    String primaryText = isAwaiting ? 'Emergency detected' : 'Emergency active';
    String secondaryText = isAwaiting ? 'Confirm if you need emergency assistance.' : 'Emergency response protocol activated.';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Row(
        children: [
          _buildPulsingRedIcon(),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(primaryText, style: AppTheme.titleStyle.copyWith(color: AppTheme.errorColor)),
                const SizedBox(height: 2),
                Text(
                  isAwaiting ? 'Awaiting confirmation' : StatusFormatter.formatEmergencyStatus(status),
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(isAwaiting ? Icons.info_outline_rounded : Icons.security_update_warning_rounded, color: AppTheme.textSecondary, size: 14),
                    const SizedBox(width: 4),
                    Expanded(child: Text(secondaryText, style: AppTheme.captionStyle.copyWith(color: AppTheme.textSecondary))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingRedIcon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryColor, size: 32),
    );
  }
}
