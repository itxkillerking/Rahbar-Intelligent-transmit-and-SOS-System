import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const PremiumHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        gradient: AppTheme.greenGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.cornerRadiusLg),
          bottomRight: Radius.circular(AppTheme.cornerRadiusLg),
        ),
      ),
      child: Stack(
        children: [
          // Subtle Watermark Background
          Align(
            alignment: const Alignment(0.25, 0.0),
            child: Opacity(
              opacity: 0.06,
              child: Image.asset(
                'assets/images/logo-bg-free.png',
                width: 250,
                fit: BoxFit.contain,
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
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/images/app_icon.png',
                                width: 42,
                                height: 42,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMedium),
                            Text(
                              'The Rahbar',
                              style: AppTheme.displayStyle.copyWith(color: Colors.white, fontSize: 24),
                            ),
                          ],
                        ),
                        if (subtitle.isNotEmpty && subtitle.contains('Transit')) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Intelligent Transit Security and SOS System',
                            style: AppTheme.captionStyle.copyWith(color: Colors.white70, fontSize: 11),
                          ),
                        ] else if (subtitle.isNotEmpty && !subtitle.contains('Stay')) ...[
                          // General subtitle for other pages if needed
                        ],
                        // Actually the user wants "Intelligent Transit..." under RAHBAR if on Home
                        // but tracking screen doesn't necessarily have it, although the previous code had it hardcoded!
                        // The original code was:
                        // Text('Intelligent Transit Security and SOS System', ...)
                        // Wait, looking at the previous code, it was hardcoded on ALL screens.
                        // I will just keep it hardcoded as it was, since the user said "do not overcrowd headers".
                        const SizedBox(height: 2),
                        Text(
                          'Intelligent Transit Security and SOS System',
                          style: AppTheme.captionStyle.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),
                        Text(
                          title,
                          style: AppTheme.displayStyle.copyWith(color: Colors.white),
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTheme.bodyStyle.copyWith(color: Colors.white70),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
