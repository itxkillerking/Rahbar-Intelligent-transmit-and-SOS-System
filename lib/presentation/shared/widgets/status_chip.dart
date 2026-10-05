import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';

enum StatusChipType {
  safe,
  warning,
  danger,
  neutral,
}

class StatusChip extends StatelessWidget {
  final String label;
  final StatusChipType type;
  final bool isAnimated;

  const StatusChip({
    Key? key,
    required this.label,
    this.type = StatusChipType.neutral,
    this.isAnimated = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color getBaseColor() {
      switch (type) {
        case StatusChipType.safe:
          return AppTheme.safeColor;
        case StatusChipType.warning:
          return AppTheme.warningColor;
        case StatusChipType.danger:
          return AppTheme.primaryColor;
        case StatusChipType.neutral:
          return AppTheme.textSecondary;
      }
    }

    final baseColor = getBaseColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusPill),
        border: Border.all(color: baseColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIndicator(baseColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: baseColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(Color color) {
    if (!isAnimated) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    return _AnimatedPulse(color: color);
  }
}

class _AnimatedPulse extends StatefulWidget {
  final Color color;
  const _AnimatedPulse({required this.color});

  @override
  State<_AnimatedPulse> createState() => _AnimatedPulseState();
}

class _AnimatedPulseState extends State<_AnimatedPulse> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
