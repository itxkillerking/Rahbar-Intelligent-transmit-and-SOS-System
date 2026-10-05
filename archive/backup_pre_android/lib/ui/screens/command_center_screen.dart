import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CommandCenterScreen extends StatelessWidget {
  const CommandCenterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Command Center', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppTheme.spacingXLarge),
            const Icon(Icons.admin_panel_settings_rounded, size: 80, color: AppTheme.textSecondary),
            const SizedBox(height: AppTheme.spacingLarge),
            const Text(
              'Web Command Center',
              style: AppTheme.displayStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'DEFERRED / FUTURE INTEGRATION',
                  style: TextStyle(color: AppTheme.warningColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
                side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Column(
                  children: [
                    Text(
                      'The RAHBAR Command Center is planned as a separate web-based emergency operations interface for authorized operators.',
                      style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    const Divider(),
                    const SizedBox(height: AppTheme.spacingMedium),
                    const Text('Future Capabilities:', style: AppTheme.titleStyle),
                    const SizedBox(height: AppTheme.spacingMedium),
                    _buildCapabilityRow(Icons.verified_user_rounded, 'Incident Verification'),
                    const SizedBox(height: AppTheme.spacingSmall),
                    _buildCapabilityRow(Icons.location_on_rounded, 'Location Monitoring'),
                    const SizedBox(height: AppTheme.spacingSmall),
                    _buildCapabilityRow(Icons.folder_shared_rounded, 'Evidence Review'),
                    const SizedBox(height: AppTheme.spacingSmall),
                    _buildCapabilityRow(Icons.support_agent_rounded, 'Response Coordination'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            Text(
              'Not included in the current mobile prototype.',
              style: AppTheme.captionStyle.copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapabilityRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        const SizedBox(width: AppTheme.spacingMedium),
        Text(label, style: AppTheme.bodyStyle),
      ],
    );
  }
}
