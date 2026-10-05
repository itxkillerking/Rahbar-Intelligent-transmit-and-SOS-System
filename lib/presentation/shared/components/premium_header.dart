import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/application/locale_controller.dart';
import 'dart:io';
import 'package:rahbar/application/profile/local_avatar_provider.dart';

class PremiumHeader extends ConsumerWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Widget? leading;
  final bool showProfileMenu;

  const PremiumHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.leading,
    this.showProfileMenu = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUrdu = ref.watch(localeProvider);
    
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.cornerRadiusLg),
          bottomRight: Radius.circular(AppTheme.cornerRadiusLg),
        ),
      ),
      child: Stack(
        children: [
          // Upper Background Asset
          Positioned.fill(
            child: Image.asset(
              'assets/images/upper_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          
          // Dark Dim Overlay for text visibility
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    AppTheme.pakistanGreen.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLarge,
                AppTheme.spacingLarge,
                AppTheme.spacingLarge,
                AppTheme.spacingXLarge,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showProfileMenu)
                        GestureDetector(
                          onTap: () {
                            final rootScaffold = context.findRootAncestorStateOfType<ScaffoldState>();
                            if (rootScaffold != null && rootScaffold.hasDrawer) {
                              rootScaffold.openDrawer();
                            } else {
                              Scaffold.maybeOf(context)?.openDrawer();
                            }
                          },
                          child: Consumer(
                            builder: (context, ref, child) {
                              final avatarPath = ref.watch(localAvatarProvider);
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.lightGreenSurface,
                                  backgroundImage: avatarPath != null ? FileImage(File(avatarPath)) : null,
                                  child: avatarPath == null ? const Icon(Icons.person, size: 24, color: AppTheme.pakistanGreen) : null,
                                ),
                              );
                            }
                          ),
                        )
                      else if (leading != null)
                        leading!,
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logo-bg-free.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                AppStrings.get(isUrdu, 'app_name'),
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                                style: AppTheme.displayStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 22,
                                  letterSpacing: 0.5,
                                  shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (showProfileMenu || leading != null)
                        // Invisible placeholder for perfect centering
                        Opacity(opacity: 0, child: IgnorePointer(child: leading ?? const SizedBox(width: 80))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.get(isUrdu, 'app_subtitle'),
                    textAlign: TextAlign.center,
                    style: AppTheme.captionStyle.copyWith(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: 12,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(height: AppTheme.spacingMedium),
                    Center(child: trailing!),
                  ],
                  const SizedBox(height: AppTheme.spacingLarge),
                  Text(
                    title,
                    style: AppTheme.displayStyle.copyWith(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.bodyStyle.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
