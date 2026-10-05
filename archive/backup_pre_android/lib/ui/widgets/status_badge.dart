import 'package:flutter/material.dart';
import '../../domain/models/emergency_status.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final EmergencyStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;

    switch (status) {
      case EmergencyStatus.idle:
      case EmergencyStatus.resolved:
        badgeColor = AppTheme.safeColor;
        label = 'SAFE';
        break;
      case EmergencyStatus.triggerDetected:
      case EmergencyStatus.awaitingConfirmation:
        badgeColor = AppTheme.warningColor;
        label = 'PENDING';
        break;
      case EmergencyStatus.failed:
        badgeColor = AppTheme.errorColor;
        label = 'FAILED';
        break;
      default:
        badgeColor = AppTheme.primaryColor;
        label = 'EMERGENCY';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: badgeColor, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
