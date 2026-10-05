import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class DomeHeaderBackground extends StatelessWidget {
  final Widget? headerContent;
  final Widget child;
  final double topPadding;
  final Widget? logo;

  const DomeHeaderBackground({
    Key? key,
    this.headerContent,
    required this.child,
    this.topPadding = 180.0,
    this.logo,
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
          
          // White Content Area with Dome Shape
          Positioned.fill(
            top: topPadding,
            child: ClipPath(
              clipper: _DomeClipper(),
              child: Container(
                color: AppTheme.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.only(top: 80.0), // Space for dome and logo
                  child: child,
                ),
              ),
            ),
          ),
          
          // Logo placed perfectly inside the dome
          if (logo != null)
            Positioned(
              top: topPadding + 6, // Adjust to sit inside the dome
              left: 0,
              right: 0,
              child: Center(child: logo!),
            ),
          
          // Header Content (Back button, language toggle, etc.)
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

class _DomeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    
    // The height of the "shoulders" (the flat parts on left and right)
    final double shoulderTop = 65.0;
    
    // Width of the central dome
    final double domeWidth = 200.0;
    final double domeHeight = 0.0; // The top of the dome touches y=0
    
    final double center = size.width / 2;
    final double domeLeft = center - (domeWidth / 2);
    final double domeRight = center + (domeWidth / 2);
    
    // Start at top left corner (below the shoulder for rounding)
    path.moveTo(0, shoulderTop + 32);
    
    // Top-left rounded corner
    path.quadraticBezierTo(0, shoulderTop, 32, shoulderTop);
    
    // Line to the start of the dome
    path.lineTo(domeLeft, shoulderTop);
    
    // Left curve up into the dome
    path.cubicTo(
      domeLeft + 30, shoulderTop,       // control point 1
      domeLeft + 30, domeHeight,        // control point 2
      center, domeHeight,               // end point (top center)
    );
    
    // Right curve down from the dome
    path.cubicTo(
      domeRight - 30, domeHeight,       // control point 1
      domeRight - 30, shoulderTop,      // control point 2
      domeRight, shoulderTop,           // end point
    );
    
    // Line to the top-right corner
    path.lineTo(size.width - 32, shoulderTop);
    
    // Top-right rounded corner
    path.quadraticBezierTo(size.width, shoulderTop, size.width, shoulderTop + 32);
    
    // Down to bottom right
    path.lineTo(size.width, size.height);
    
    // To bottom left
    path.lineTo(0, size.height);
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
