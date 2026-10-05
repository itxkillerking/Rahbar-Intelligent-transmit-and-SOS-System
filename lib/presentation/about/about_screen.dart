import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/components/authenticated_drawer.dart';
import 'package:rahbar/presentation/shared/components/rahbar_menu_button.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AuthenticatedDrawer(),
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            Builder(
              builder: (ctx) => RahbarMenuButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const BackButton(),
          ],
        ),
        title: const Text('About RAHBAR'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingLarge),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
                      boxShadow: AppTheme.premiumShadow,
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                          child: const Icon(Icons.shield_rounded, size: 40, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(height: AppTheme.spacingMedium),
                        const Text(
                          'RAHBAR',
                          style: AppTheme.headingStyle,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Prototype Version 1.0',
                          style: AppTheme.captionStyle,
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),
                        const Text(
                          'RAHBAR is an intelligent transit security and SOS system designed for personal safety and emergency assistance.',
                          textAlign: TextAlign.center,
                          style: AppTheme.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLarge),
                  const Text('Main Capabilities', style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildCapability(Icons.emergency_share_rounded, 'SOS Alerts', 'One-touch emergency notifications to authorities and trusted contacts.'),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildCapability(Icons.group_rounded, 'Guardians', 'Build a personal safety network of trusted family and friends.'),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildCapability(Icons.location_on_rounded, 'Live Tracking', 'Share your real-time location during transit or emergencies.'),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildCapability(Icons.camera_alt_rounded, 'Evidence Collection', 'Securely capture and store audio/video evidence.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapability(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(desc, style: AppTheme.captionStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
