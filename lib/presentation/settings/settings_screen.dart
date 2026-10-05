import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/fake_call_controller.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/settings/development_controls.dart';
import 'package:rahbar/presentation/profile/profile_screen.dart';
import 'package:rahbar/presentation/shared/components/premium_header.dart';
import 'package:rahbar/presentation/shared/widgets/status_chip.dart';
import 'package:rahbar/application/locale_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = ref.watch(localeProvider);
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
              title: AppStrings.get(isUrdu, 'settings'),
              subtitle: 'Manage your safety features and prototype controls',
              showProfileMenu: true,
              trailing: StatusChip(
                label: AppStrings.get(isUrdu, 'system_active'),
                type: StatusChipType.safe,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  Text(AppStrings.get(isUrdu, 'account_profile'), style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  _buildAccountSection(context, ref, isUrdu),

                  const SizedBox(height: AppTheme.spacingLarge),
                  
                  Text(AppStrings.get(isUrdu, 'safety_features'), style: AppTheme.titleStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  const FakeCallSection(),
                  
                  const SizedBox(height: AppTheme.spacingXLarge),
                  
                  Text(AppStrings.get(isUrdu, 'developer_tools'), style: AppTheme.titleStyle),
                  const SizedBox(height: 4),
                  const Text('For FYP demonstration only', style: AppTheme.captionStyle),
                  const SizedBox(height: AppTheme.spacingMedium),
                  
                  const DevelopmentControls(),
                  
                  const SizedBox(height: AppTheme.spacingXLarge),
                  Center(
                    child: Text(
                      'RAHBAR: Intelligent Transit Security and SOS System\nPrototype Version 1.0',
                      textAlign: TextAlign.center,
                      style: AppTheme.captionStyle.copyWith(color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, WidgetRef ref, bool isUrdu) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        children: [
          if (profile != null) ...[
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.lightGreenSurface,
                child: const Icon(Icons.person, color: AppTheme.pakistanGreen),
              ),
              title: Text(profile.fullName ?? 'User Profile', style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.username ?? profile.phoneNumber ?? '', style: AppTheme.captionStyle),
                  const SizedBox(height: 4),
                  Text('Profile ${profile.completionPercentage}% complete', style: AppTheme.captionStyle.copyWith(color: AppTheme.pakistanGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
            const Divider(height: 1),
          ],
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.errorColor),
            title: Text(AppStrings.get(isUrdu, 'logout'), style: const TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
            onTap: () {
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class FakeCallSection extends ConsumerWidget {
  const FakeCallSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fakeCallControllerProvider);
    final isUrdu = ref.watch(localeProvider);
    final themeColor = state.isBlocked ? AppTheme.errorColor : AppTheme.accentBlue;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: state.isBlocked ? AppTheme.errorColor.withValues(alpha: 0.3) : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone_in_talk_rounded, color: themeColor),
                ),
                const SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.get(isUrdu, 'fake_call_protection'), style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('Attempts Used: ${state.attemptsUsed} / ${FakeCallState.threshold}', style: AppTheme.captionStyle),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: state.attemptsUsed / FakeCallState.threshold,
                backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                minHeight: 6,
              ),
            ),
          ),
          
          if (state.isBlocked) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm),
                  border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.block_rounded, color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: Text(
                        'Fake Call Temporarily Blocked\n4 of 4 prototype attempts used. Reset prototype history to continue demonstration.',
                        style: AppTheme.captionStyle.copyWith(color: AppTheme.errorColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: AppTheme.spacingMedium),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium),
            child: ElevatedButton.icon(
              onPressed: state.isBlocked
                  ? null
                  : () async {
                      final success = await ref.read(fakeCallControllerProvider.notifier).triggerFakeCall();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Prototype fake call triggered'),
                            backgroundColor: AppTheme.accentBlue,
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.call_rounded),
              label: const Text('TRIGGER FAKE CALL'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
                foregroundColor: Colors.white,
                elevation: state.isBlocked ? 0 : 2,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
              ),
            ),
          ),
          
          if (state.history.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingLarge),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prototype History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: AppTheme.spacingSmall),
                  ...state.history.map((attempt) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 14, color: AppTheme.textSecondary.withValues(alpha: 0.5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${attempt.timestamp.hour}:${attempt.timestamp.minute.toString().padLeft(2, '0')}',
                              style: AppTheme.captionStyle,
                            ),
                          ),
                          Text(
                            attempt.status,
                            style: AppTheme.captionStyle.copyWith(color: AppTheme.safeColor, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: AppTheme.spacingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showResetConfirmation(context, ref);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Reset Prototype History'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: BorderSide(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: AppTheme.spacingMedium),
          ],
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg)),
        title: Row(
          children: [
            const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            const Text('Reset History?', style: AppTheme.titleStyle),
          ],
        ),
        content: const Text(
          'This will clear your fake call prototype history and restore all 4 attempts. Continue?',
          style: AppTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(fakeCallControllerProvider.notifier).resetPrototype();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prototype history reset'),
                  backgroundColor: AppTheme.safeColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill)),
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
