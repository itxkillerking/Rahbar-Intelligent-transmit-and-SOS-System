import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_text_field.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_text_field.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_primary_button.dart';
import 'package:rahbar/presentation/shared/widgets/language_toggle_pill.dart';
import 'package:rahbar/application/locale_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  String? _inlineError;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutQuart));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() {
    FocusScope.of(context).unfocus();
    final phone = _phoneController.text.trim();
    
    // Client side validation
    if (phone.isEmpty) {
      setState(() => _inlineError = "Phone number is required.");
      return;
    }
    
    if (phone.length < 11) {
      setState(() => _inlineError = "Phone number is missing ${11 - phone.length} digits.");
      return;
    }

    if (phone.length > 11) {
      setState(() => _inlineError = "Phone number has ${phone.length - 11} extra digits.");
      return;
    }

    if (!phone.startsWith('03')) {
      setState(() => _inlineError = "Enter a Pakistani mobile number starting with 03.");
      return;
    }

    setState(() => _inlineError = null);
    ref.read(authControllerProvider.notifier).requestOtp(phone);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.status == AuthState.requestingOtp;
    final isUrdu = ref.watch(localeProvider);
    final displayError = _inlineError ?? authState.errorMessage;
    
    return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/login_background.png',
                fit: BoxFit.cover,
                alignment: Alignment.bottomCenter,
              ),
            ),
            // Gradient Overlay for Readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                                // Logo and Branding
                                Center(
                                  child: Image.asset(
                                    'assets/images/logo-bg-free.png',
                                    height: 80,
                                  ),
                                ),
                                const SizedBox(height: AppTheme.spacingMedium),
                                Text(
                                  AppStrings.get(isUrdu, 'app_name'),
                                  textAlign: TextAlign.center,
                                  style: AppTheme.displayStyle.copyWith(
                                    color: Colors.white,
                                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.get(isUrdu, 'app_subtitle'),
                                  textAlign: TextAlign.center,
                                  style: AppTheme.bodyStyle.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontWeight: FontWeight.w600,
                                    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))]
                                  ),
                                ),
                                
                                const SizedBox(height: 40),
                                
                                // Login Card
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        'Enter Your Phone Number', // Usually uses localization, but matching design
                                        style: AppTheme.displayStyle.copyWith(fontSize: 22, color: const Color(0xFF0F172A)),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 12),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary, height: 1.5),
                                          children: [
                                            const TextSpan(text: "We'll send you "),
                                            TextSpan(text: "an OTP ", style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                            const TextSpan(text: "for secure "),
                                            TextSpan(text: "login\n", style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                                            const TextSpan(text: "or registration"),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      
                                      // Custom Phone Input Field
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppTheme.pakistanGreen.withValues(alpha: 0.3)),
                                          borderRadius: BorderRadius.circular(16),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                              decoration: BoxDecoration(
                                                color: AppTheme.lightGreenSurface.withValues(alpha: 0.5),
                                                borderRadius: const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomLeft: Radius.circular(16),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 24,
                                                    height: 24,
                                                    decoration: const BoxDecoration(
                                                      color: AppTheme.pakistanGreen,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(Icons.star_border, size: 14, color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text('+92', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextFormField(
                                                controller: _phoneController,
                                                keyboardType: TextInputType.phone,
                                                style: const TextStyle(fontSize: 18, letterSpacing: 1.5, color: AppTheme.textPrimary),
                                                decoration: const InputDecoration(
                                                  hintText: '03XX XXX XXXX',
                                                  hintStyle: TextStyle(color: Colors.black38, letterSpacing: 1.0),
                                                  border: InputBorder.none,
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.zero,
                                                ),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter.digitsOnly,
                                                  LengthLimitingTextInputFormatter(11),
                                                ],
                                                onChanged: (_) {
                                                  if (_inlineError != null) setState(() => _inlineError = null);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Validation Message
                                      if (displayError != null) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(child: Text(displayError, style: const TextStyle(color: AppTheme.errorColor, fontSize: 13))),
                                          ],
                                        ),
                                      ] else ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Icon(Icons.check_circle, color: AppTheme.pakistanGreen, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Enter a valid 11 digit phone number\ne.g. 03XX XXX XXXX',
                                                style: TextStyle(color: AppTheme.pakistanGreen.withValues(alpha: 0.8), fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Custom Premium Send OTP Button
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
                                            onTap: isLoading ? null : _validateAndSubmit,
                                            borderRadius: BorderRadius.circular(28),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: isLoading
                                                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                                  : Row(
                                                      children: [
                                                        const SizedBox(width: 16),
                                                        const Icon(Icons.send_rounded, color: Colors.white),
                                                        Expanded(
                                                          child: Text(
                                                            AppStrings.get(isUrdu, 'send_otp'),
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
                                                          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Bottom Note
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.textSecondary.withValues(alpha: 0.05),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.lock_rounded, size: 20, color: AppTheme.textSecondary),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                AppStrings.get(isUrdu, 'secure_login_msg'),
                                                style: AppTheme.captionStyle.copyWith(color: AppTheme.textSecondary, fontSize: 12, height: 1.4),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Foreground overlay elements
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLarge, vertical: 8),
                child: Align(
                  alignment: Alignment.topRight,
                  child: LanguageTogglePill(
                    isUrdu: isUrdu,
                    onChanged: (val) => ref.read(localeProvider.notifier).setUrdu(val),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}
