import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rahbar/core/theme/app_theme.dart';

class OtpCodeInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final bool hasError;

  const OtpCodeInput({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hasError = false,
  }) : super(key: key);

  @override
  State<OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<OtpCodeInput> {
  final FocusNode _focusNode = FocusNode();
  String _currentValue = '';
  int _cursorIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.controller.text;
    _cursorIndex = _currentValue.length;
    widget.controller.addListener(_onControllerChange);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {}); // trigger rebuild to show/hide focus border
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    bool needsUpdate = false;
    if (_currentValue != widget.controller.text) {
      _currentValue = widget.controller.text;
      widget.onChanged(_currentValue);
      needsUpdate = true;
    }
    
    int newCursor = widget.controller.selection.isValid ? widget.controller.selection.baseOffset : _currentValue.length;
    if (newCursor < 0) newCursor = 0;
    if (newCursor > 6) newCursor = 6;
    
    if (_cursorIndex != newCursor) {
      _cursorIndex = newCursor;
      needsUpdate = true;
    }
    
    if (needsUpdate) {
      setState(() {});
    }
  }

  void _handleBoxTap(int index) {
    if (!_focusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_focusNode);
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
    
    int targetIndex = index;
    if (targetIndex > _currentValue.length) {
      targetIndex = _currentValue.length;
    }
    widget.controller.selection = TextSelection.collapsed(offset: targetIndex);
    setState(() {
      _cursorIndex = targetIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
          // Invisible TextField for seamless native keyboard/paste integration
          Opacity(
            opacity: 0.0,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
          // Visible UI
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              bool isFocused = _focusNode.hasFocus && _cursorIndex == index;
              if (_focusNode.hasFocus && _currentValue.length == 6 && index == 5) {
                isFocused = true;
              }
              final isFilled = _currentValue.length > index;
              final char = isFilled ? _currentValue[index] : '';
              
              Color borderColor = const Color(0xFFE2E8F0);
              Color bgColor = Colors.white;
              
              if (widget.hasError) {
                borderColor = AppTheme.errorColor;
                bgColor = AppTheme.errorColor.withValues(alpha: 0.05);
              } else if (isFocused) {
                borderColor = const Color(0xFF0A7B44);
                bgColor = const Color(0xFFF0FAF5);
              } else if (isFilled) {
                borderColor = const Color(0xFFE2E8F0);
                bgColor = Colors.white;
              }

              Widget content;
              if (char.isNotEmpty) {
                content = Text(
                  char,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: widget.hasError ? AppTheme.errorColor : AppTheme.secondaryColor,
                  ),
                );
              } else if (isFocused) {
                content = Container(
                  width: 2,
                  height: 24,
                  color: const Color(0xFF0A7B44),
                );
              } else {
                content = Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCBD5E1),
                    shape: BoxShape.circle,
                  ),
                );
              }

              return GestureDetector(
                onTap: () => _handleBoxTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: isFocused ? 1.5 : 1.0),
                  ),
                  child: content,
                ),
              );
            }),
          ),
        ],
    );
  }
}
