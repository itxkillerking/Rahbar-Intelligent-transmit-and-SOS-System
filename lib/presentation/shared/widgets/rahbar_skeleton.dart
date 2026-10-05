import 'package:flutter/material.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class RahbarSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const RahbarSkeleton({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = AppTheme.cornerRadiusSm,
  }) : super(key: key);

  @override
  State<RahbarSkeleton> createState() => _RahbarSkeletonState();
}

class _RahbarSkeletonState extends State<RahbarSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      );
    }
    
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
