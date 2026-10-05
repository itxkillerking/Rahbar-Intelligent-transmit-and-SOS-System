import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/application/navigation_controller.dart';
import 'package:rahbar/presentation/evidence/evidence_screen.dart';
import 'package:rahbar/presentation/about/about_screen.dart';
import 'package:rahbar/presentation/about/privacy_screen.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_skeleton.dart';
import 'package:rahbar/application/locale_controller.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/application/profile/local_avatar_provider.dart';

import 'dart:io';

class RahbarDrawer extends ConsumerWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;
  final String fullName;
  final String identifier;
  final int completionPercentage;
  final bool isLoading;
  final bool hasError;

  const RahbarDrawer({
    Key? key,
    required this.onProfileTap,
    required this.onLogoutTap,
    required this.fullName,
    required this.identifier,
    required this.completionPercentage,
    this.isLoading = false,
    this.hasError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(appShellIndexProvider);
    final isUrdu = ref.watch(localeProvider);
    
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topRight: Radius.circular(24), bottomRight: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: onProfileTap,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            value: completionPercentage / 100,
                            backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.1),
                            color: AppTheme.pakistanGreen,
                            strokeWidth: 3,
                          ),
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final avatarPath = ref.watch(localAvatarProvider);
                            return CircleAvatar(
                              radius: 24,
                              backgroundColor: AppTheme.lightGreenSurface,
                              backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
                              child: avatarPath == null ? const Icon(Icons.person, color: AppTheme.pakistanGreen) : null,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: isLoading
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                RahbarSkeleton(width: 120, height: 18),
                                SizedBox(height: 6),
                                RahbarSkeleton(width: 80, height: 12),
                                SizedBox(height: 6),
                                RahbarSkeleton(width: 100, height: 12),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(fullName, style: AppTheme.titleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (identifier.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(identifier, style: AppTheme.captionStyle),
                                ],
                                if (!hasError) ...[
                                  const SizedBox(height: 4),
                                  Text('Profile $completionPercentage% complete', style: AppTheme.captionStyle.copyWith(color: AppTheme.pakistanGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ],
                            ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary),
                  ],
                ),
              ),
            ),
            
            const Divider(height: 1),
            
            // Language Switch
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
                  border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(localeProvider.notifier).setUrdu(false); // English
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !isUrdu ? AppTheme.pakistanGreen.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
                          ),
                          alignment: Alignment.center,
                          child: Text('English', style: TextStyle(fontWeight: FontWeight.bold, color: !isUrdu ? AppTheme.pakistanGreen : AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          ref.read(localeProvider.notifier).setUrdu(true); // Urdu
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isUrdu ? AppTheme.pakistanGreen.withValues(alpha: 0.1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
                          ),
                          alignment: Alignment.center,
                          child: Text('اردو', style: TextStyle(fontWeight: FontWeight.bold, color: isUrdu ? AppTheme.pakistanGreen : AppTheme.textSecondary)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
                children: [
                  _DrawerItem(icon: Icons.home_rounded, title: AppStrings.get(isUrdu, 'home'), isSelected: currentIndex == 0, onTap: () {
                    _navigateToTab(context, ref, 0);
                  }),
                  _DrawerItem(icon: Icons.person_rounded, title: AppStrings.get(isUrdu, 'my_profile'), onTap: () {
                    Navigator.pop(context);
                    onProfileTap();
                  }),
                  _DrawerItem(icon: Icons.location_on_rounded, title: AppStrings.get(isUrdu, 'live_tracking'), isSelected: currentIndex == 1, onTap: () {
                    _navigateToTab(context, ref, 1);
                  }),
                  _DrawerItem(icon: Icons.group_rounded, title: AppStrings.get(isUrdu, 'guardians'), isSelected: currentIndex == 2, onTap: () {
                    _navigateToTab(context, ref, 2);
                  }),
                  _DrawerItem(icon: Icons.camera_alt_rounded, title: AppStrings.get(isUrdu, 'evidence'), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EvidenceScreen()));
                  }),
                  _DrawerItem(icon: Icons.settings_rounded, title: AppStrings.get(isUrdu, 'settings'), isSelected: currentIndex == 3, onTap: () {
                    _navigateToTab(context, ref, 3);
                  }),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium, horizontal: AppTheme.spacingMedium),
                    child: Divider(),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMedium, vertical: 8),
                    child: Text(AppStrings.get(isUrdu, 'information'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textSecondary, letterSpacing: 1.2)),
                  ),
                  _DrawerItem(icon: Icons.info_outline_rounded, title: AppStrings.get(isUrdu, 'about'), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                  }),
                  _DrawerItem(icon: Icons.privacy_tip_outlined, title: AppStrings.get(isUrdu, 'privacy'), onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()));
                  }),
                ],
              ),
            ),
            
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingSmall),
              child: _DrawerItem(
                icon: Icons.logout_rounded,
                title: AppStrings.get(isUrdu, 'logout'),
                iconColor: AppTheme.errorColor,
                textColor: AppTheme.errorColor,
                onTap: onLogoutTap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, WidgetRef ref, int index) {
    Navigator.pop(context); // Close the drawer
    
    bool wasPushed = false;
    Navigator.popUntil(context, (route) {
      if (route.isFirst) return true;
      wasPushed = true;
      return false;
    });

    if (wasPushed) {
      if (kDebugMode) debugPrint('NAV: returning pushed route → AppShell index $index');
    } else {
      if (kDebugMode) debugPrint('NAV: Profile drawer → Home/Tab $index');
    }

    ref.read(appShellIndexProvider.notifier).state = index;
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? iconColor;
  final Color? textColor;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isSelected = false,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppTheme.pakistanGreen : (iconColor ?? AppTheme.textSecondary);
    final bg = isSelected ? AppTheme.pakistanGreen.withValues(alpha: 0.1) : Colors.transparent;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: AppTheme.bodyStyle.copyWith(color: textColor ?? (isSelected ? AppTheme.pakistanGreen : AppTheme.textPrimary), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.cornerRadiusSm)),
      tileColor: bg,
      onTap: onTap,
    );
  }
}
