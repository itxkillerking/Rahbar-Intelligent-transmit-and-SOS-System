import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/components/authenticated_drawer.dart';
import 'package:rahbar/presentation/shared/components/rahbar_menu_button.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

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
        title: const Text('Privacy Policy'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingLarge),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
                  boxShadow: AppTheme.premiumShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
                        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor),
                          const SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: Text(
                              'Pending Legal Review',
                              style: AppTheme.bodyStyle.copyWith(color: AppTheme.warningColor, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLarge),
                    const Text(
                      'The formal legal privacy policy is currently pending finalization for this prototype.',
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: AppTheme.spacingMedium),
                    const Text(
                      'As a core principle, RAHBAR is designed to protect your personal data, location information, and captured evidence with industry-standard encryption. Your emergency contacts and sensitive details are only shared during active SOS events.',
                      style: AppTheme.bodyStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
