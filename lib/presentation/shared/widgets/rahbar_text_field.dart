import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rahbar/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/locale_controller.dart';

class RahbarTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final TextInputType keyboardType;
  final String? errorText;
  final bool autofocus;
  final Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const RahbarTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.autofocus = false,
    this.onChanged,
    this.inputFormatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasError = errorText != null;
    final isUrdu = ref.watch(localeProvider);
    final textDir = isUrdu ? TextDirection.rtl : TextDirection.ltr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 64, // Fixed height for consistency
          decoration: BoxDecoration(
            color: hasError ? AppTheme.errorColor.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppTheme.errorColor : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: hasError ? AppTheme.errorColor.withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                  ),
                  child: Center(
                    child: Icon(
                      prefixIcon,
                      color: hasError ? AppTheme.errorColor : const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                ),
                Container(width: 1, color: const Color(0xFFE2E8F0)),
              ],
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  autofocus: autofocus,
                  onChanged: onChanged,
                  inputFormatters: inputFormatters,
                  textDirection: textDir,
                  textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                  style: AppTheme.bodyStyle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    labelStyle: AppTheme.captionStyle.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                    ),
                    floatingLabelStyle: AppTheme.captionStyle.copyWith(
                      color: const Color(0xFF64748B),
                      fontSize: 12,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintStyle: AppTheme.captionStyle.copyWith(color: AppTheme.textSecondary.withValues(alpha: 0.4)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                  ),
                ),
              ),
            ],
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => SizeTransition(sizeFactor: animation, child: FadeTransition(opacity: animation, child: child)),
          child: hasError
              ? Padding(
                  key: ValueKey(errorText),
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          errorText!,
                          style: AppTheme.captionStyle.copyWith(color: AppTheme.errorColor),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('no_error')),
        ),
      ],
    );
  }
}
