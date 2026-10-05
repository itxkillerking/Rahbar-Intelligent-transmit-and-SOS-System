import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/auth/components/otp_code_input.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_primary_button.dart';
import 'package:flutter/foundation.dart';
import 'package:rahbar/data/repositories/auth_repository.dart';
import 'package:rahbar/presentation/shared/widgets/dome_header_background.dart';
import 'package:rahbar/presentation/shared/widgets/language_toggle_pill.dart';
import 'package:rahbar/application/locale_controller.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with SingleTickerProviderStateMixin {
  final _otpController = TextEditingController();
  bool _isUrdu = false;
  int _countdown = 60;
  Timer? _timer;
  String? _inlineError;

  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeCtrl.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  void _shakeError() {
    _shakeCtrl.forward(from: 0.0);
  }

  void _verify() {
    FocusScope.of(context).unfocus();
    final otp = _otpController.text.trim();

    if (otp.length < 6) {
      setState(() => _inlineError = "OTP is missing ${6 - otp.length} digits.");
      _shakeError();
      return;
    }

    setState(() => _inlineError = null);
    ref.read(authControllerProvider.notifier).verifyOtp(otp);
  }

  void _resend() {
    final phone = ref.read(authControllerProvider).phoneNumber;
    if (phone != null) {
      ref.read(authControllerProvider.notifier).requestOtp(phone);
      _startCountdown();
      setState(() => _inlineError = null);
      _otpController.clear();
    }
  }

  Future<void> _devGetOtp() async {
    final phone = ref.read(authControllerProvider).phoneNumber;
    if (phone != null) {
      final otp = await ref.read(authRepositoryProvider).getDevOtp(phone);
      if (otp != null) {
        _otpController.text = otp;
        _verify();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isVerifying = authState.status == AuthState.verifyingOtp;
    final textDirection = _isUrdu ? TextDirection.rtl : TextDirection.ltr;
    final canResend = _countdown == 0;

    final displayError = _inlineError ?? authState.errorMessage;
    if (authState.errorMessage != null && _inlineError == null) {
      // Backend error occurred (invalid OTP usually triggers state update)
      // We don't want to infinite loop, but a shake on re-build if it's an error state
      if (!isVerifying && authState.errorMessage!.contains('Invalid')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_shakeCtrl.isAnimating) _shakeCtrl.forward(from: 0.0);
        });
      }
    }

    // Mask phone number
    String maskedPhone = authState.phoneNumber ?? '';
    if (maskedPhone.length == 11) {
      maskedPhone =
          '${maskedPhone.substring(0, 4)}••••${maskedPhone.substring(8)}';
    }

    return DomeHeaderBackground(
        topPadding: 160.0,
        logo: Image.asset('assets/images/logo-bg-free.png', height: 75),
        headerContent: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF0F172A), size: 18),
                      onPressed: () =>
                          ref.read(authControllerProvider.notifier).cancelOtpProcess(),
                    ),
                  ),
                  LanguageTogglePill(
                    isUrdu: _isUrdu,
                    onChanged: (val) => setState(() => _isUrdu = val),
                  ),
                ],
              ),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingLarge),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: AppTheme.spacingXLarge),
                          Text(
                            AppStrings.get(_isUrdu, 'app_name'),
                            textAlign: TextAlign.center,
                            style: AppTheme.displayStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontSize: 22,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingLarge),
                          Text(
                            _isUrdu
                                ? 'OTP درج کریں'
                                : 'Enter OTP',
                            textAlign: TextAlign.center,
                            style: AppTheme.displayStyle.copyWith(fontSize: 32, color: const Color(0xFF0A7B44)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_isUrdu ? 'کوڈ بھیجا گیا' : 'Code sent to'} $maskedPhone',
                            textAlign: TextAlign.center,
                            style: AppTheme.bodyStyle
                                .copyWith(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 32),

                          // Shake animation for error
                          AnimatedBuilder(
                            animation: _shakeCtrl,
                            builder: (context, child) {
                              final offset = (1.0 - _shakeCtrl.value) *
                                  10 *
                                  (_shakeCtrl.value > 0
                                      ? (0.5 - (_shakeCtrl.value * 4 % 1.0))
                                                  .abs() *
                                              2 -
                                          1
                                      : 0);
                              return Transform.translate(
                                offset: Offset(offset, 0),
                                child: child,
                              );
                            },
                            child: OtpCodeInput(
                              controller: _otpController,
                              hasError: displayError != null,
                              onChanged: (val) {
                                if (displayError != null)
                                  setState(() => _inlineError = null);
                                if (val.length == 6 && !isVerifying) {
                                  _verify();
                                }
                              },
                            ),
                          ),

                          if (displayError != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF1F2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE11D48),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(2),
                                    child: const Icon(Icons.priority_high_rounded,
                                        color: Colors.white, size: 14),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: Text(
                                      displayError,
                                      style: AppTheme.bodyStyle
                                          .copyWith(color: const Color(0xFFE11D48), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          // Custom Premium Verify Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0A7B44), Color(0xFF0F9856)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0A7B44).withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: isVerifying ? null : _verify,
                                borderRadius: BorderRadius.circular(28),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: isVerifying
                                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                      : Row(
                                          children: [
                                            const SizedBox(width: 48), // Balance space
                                            Expanded(
                                              child: Text(
                                                _isUrdu ? 'تصدیق کریں' : 'Verify',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Footer actions
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FAF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time_rounded, color: Color(0xFF0A7B44), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _isUrdu ? 'کوڈ دوبارہ بھیجیں' : 'Resend code in',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '00:${_countdown.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Color(0xFF0A7B44), fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                const Spacer(),
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: Colors.black12,
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: canResend ? _resend : null,
                                  child: Row(
                                    children: [
                                      Icon(Icons.send_rounded, 
                                        color: canResend ? const Color(0xFF0A7B44) : AppTheme.textSecondary.withValues(alpha: 0.5), 
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        _isUrdu ? 'دوبارہ بھیجیں' : 'Resend OTP',
                                        style: TextStyle(
                                          color: canResend ? const Color(0xFF0A7B44) : AppTheme.textSecondary.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE6F4EA),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_rounded, color: Color(0xFF0A7B44), size: 12),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _isUrdu
                                      ? 'آپ کا نمبر محفوظ ہے۔'
                                      : 'Your number is securely verified and kept private\nfor your safety.',
                                  style: AppTheme.captionStyle
                                      .copyWith(color: AppTheme.textSecondary, height: 1.4, fontSize: 11),
                                ),
                              ),
                            ],
                          ),

                          if (kDebugMode)
                            TextButton(
                              onPressed: _devGetOtp,
                              child: const Text('Get dev OTP (Debug Only)',
                                  style: TextStyle(color: AppTheme.errorColor)),
                            ),

                          const Spacer(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
  }
}
