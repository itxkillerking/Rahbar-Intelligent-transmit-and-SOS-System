import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class CurvedHeaderBackground extends StatelessWidget {
  final Widget? headerContent;
  final Widget child;
  final double topPadding;

  const CurvedHeaderBackground({
    Key? key,
    this.headerContent,
    required this.child,
    this.topPadding = 160.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Image.asset(
              'assets/images/upper_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          
          // Dark Dim Overlay for text visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
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
          
          // White Content Area
          Positioned.fill(
            top: topPadding,
            child: Container(
              decoration: const BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: child,
            ),
          ),
          
          // Header Content (Logo, language toggle, etc.)
          if (headerContent != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: headerContent!,
              ),
            ),
        ],
      ),
    );
  }
}
