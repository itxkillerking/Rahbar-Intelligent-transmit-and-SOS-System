import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_text_field.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_primary_button.dart';
import 'package:rahbar/core/data/pakistan_locations.dart';
import 'package:rahbar/presentation/shared/widgets/location_picker_sheet.dart';
import 'package:rahbar/presentation/shared/widgets/dome_header_background.dart';
import 'package:rahbar/application/locale_controller.dart';

class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _fullNameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _provinceCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  int _currentStep = 1;
  bool _isSubmitting = false;
  String? _fullNameError;
  String? _usernameError;
  String? _cnicError;
  String? _provinceError;
  String? _cityError;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authControllerProvider).profile;
    if (profile != null) {
      _fullNameCtrl.text = profile.fullName ?? '';
      _usernameCtrl.text = profile.username ?? '';
      _cnicCtrl.text = profile.cnic ?? '';
      _provinceCtrl.text = profile.province ?? '';
      _cityCtrl.text = profile.city ?? '';
      _districtCtrl.text = profile.district ?? '';
      _addressCtrl.text = profile.address ?? '';
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _usernameCtrl.dispose();
    _cnicCtrl.dispose();
    _provinceCtrl.dispose();
    _cityCtrl.dispose();
    _districtCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  bool _validateStep1() {
    bool isValid = true;
    setState(() {
      _fullNameError = null;
      _usernameError = null;
      _cnicError = null;
    });

    final name = _fullNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _fullNameError = "Full name is required.");
      isValid = false;
    }

    final user = _usernameCtrl.text.trim();
    if (user.isEmpty) {
      setState(() => _usernameError = "Username is required.");
      isValid = false;
    } else if (user.length < 3) {
      setState(() => _usernameError =
          "Username needs ${3 - user.length} more character(s).");
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(user)) {
      setState(
          () => _usernameError = "Use only letters, numbers and underscore.");
      isValid = false;
    }

    final cnicRaw = _cnicCtrl.text.trim();
    final cnicDigits = cnicRaw.replaceAll(RegExp(r'[- ]'), '');
    if (cnicDigits.isEmpty) {
      setState(() => _cnicError = "CNIC is required.");
      isValid = false;
    } else if (!RegExp(r'^[0-9-]+$').hasMatch(cnicRaw)) {
      setState(() =>
          _cnicError = "CNIC can contain digits and formatting dashes only.");
      isValid = false;
    } else if (cnicDigits.length < 13) {
      setState(() =>
          _cnicError = "CNIC is missing ${13 - cnicDigits.length} digits.");
      isValid = false;
    } else if (cnicDigits.length > 13) {
      setState(() =>
          _cnicError = "CNIC has ${cnicDigits.length - 13} extra digit(s).");
      isValid = false;
    }

    return isValid;
  }

  bool _validateStep2() {
    bool isValid = true;
    setState(() {
      _provinceError = null;
      _cityError = null;
    });

    if (_provinceCtrl.text.trim().isEmpty) {
      setState(() => _provinceError = "Province is required.");
      isValid = false;
    }

    if (_cityCtrl.text.trim().isEmpty) {
      setState(() => _cityError = "City is required.");
      isValid = false;
    }

    return isValid;
  }

  void _nextStep() {
    if (_validateStep1()) {
      FocusScope.of(context).unfocus();
      if (kDebugMode) debugPrint('PROFILE: step 1 → 2');
      setState(() => _currentStep = 2);
    }
  }

  void _updateLater() {
    if (!_validateStep1()) {
      setState(() => _currentStep = 1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the required fields to continue.'), backgroundColor: Colors.red),
      );
      return;
    }
    if (!_validateStep2()) {
      setState(() => _currentStep = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the required location fields to continue.'), backgroundColor: Colors.red),
      );
      return;
    }
    // If required fields are valid, submit to save them and continue to Home.
    _submit();
  }

  void _submit() async {
    if (!_validateStep1()) return;
    if (!_validateStep2()) return;

    FocusScope.of(context).unfocus();
    if (kDebugMode) debugPrint('PROFILE: update started');

    final payload = {
      'full_name': _fullNameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'cnic': _cnicCtrl.text.trim(),
      'province': _provinceCtrl.text.trim(),
      'city': _cityCtrl.text.trim(),
    };

    if (_districtCtrl.text.trim().isNotEmpty) {
      payload['district'] = _districtCtrl.text.trim();
    }
    if (_addressCtrl.text.trim().isNotEmpty) {
      payload['address'] = _addressCtrl.text.trim();
    }

    setState(() => _isSubmitting = true);
    await ref.read(authControllerProvider.notifier).submitProfile(payload);
    if (kDebugMode) debugPrint('PROFILE: update success');
    if (mounted) setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isUrdu = ref.watch(localeProvider);

    // I'll manage loading locally since controller returns immediately on error.
    return PopScope(
      canPop: _currentStep == 1,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 1) {
          if (kDebugMode) debugPrint('NAV: system back on Profile (step $_currentStep → ${_currentStep - 1})');
          setState(() => _currentStep -= 1);
        }
      },
      child: DomeHeaderBackground(
        topPadding: 160.0,
        logo: Image.asset('assets/images/logo-bg-free.png', height: 48),
        headerContent: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingLarge, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 1)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                    onPressed: () => setState(() => _currentStep -= 1),
                  ),
                )
              else
                const SizedBox(width: 48), // Placeholder to balance row
                
              // Update Later Pill
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _updateLater,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.white, size: 14),
                        const SizedBox(width: 6),
                        Text('Update later\nfrom Settings',
                            textAlign: TextAlign.center,
                            style: AppTheme.captionStyle.copyWith(
                                color: Colors.white, fontSize: 10, height: 1.1)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLarge),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.get(isUrdu, 'complete_profile'),
                        textAlign: TextAlign.center,
                        style: AppTheme.displayStyle.copyWith(
                          color: AppTheme.primaryColor,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Provide your details for better safety and a\nmore personalized experience.',
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyStyle.copyWith(color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      _buildStepIndicator(),
                      const SizedBox(height: 32),
                      const SizedBox(height: AppTheme.spacingXLarge),
                      if (authState.errorMessage != null &&
                          authState.errorMessage!.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                                AppTheme.cornerRadiusSm),
                            border: Border.all(
                                color: AppTheme.errorColor
                                    .withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_rounded,
                                  color: AppTheme.errorColor, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: Text(authState.errorMessage!,
                                      style: const TextStyle(
                                          color: AppTheme.errorColor,
                                          fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingLarge),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child:
                            _currentStep == 1 ? _buildStep1() : _buildStep2(),
                      ),
                      const SizedBox(height: AppTheme.spacingLarge),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                child: RahbarPrimaryButton(
                  label: AppStrings.get(isUrdu, 'save_continue'),
                  onPressed: _isSubmitting ? null : (_currentStep == 1 ? _nextStep : _submit),
                  isLoading: _isSubmitting,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(isCompleted: true),
            _buildLine(isCompleted: true),
            _buildDot(isCompleted: _currentStep >= 1, isActive: _currentStep == 1),
            _buildLine(isCompleted: _currentStep >= 2),
            _buildDot(isCompleted: _currentStep >= 2, isActive: _currentStep == 2),
            _buildLine(isCompleted: _currentStep >= 3),
            _buildDot(isCompleted: _currentStep >= 3, isActive: _currentStep == 3),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text('Step $_currentStep of 2',
              style: AppTheme.captionStyle
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildDot({required bool isCompleted, bool isActive = false}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.white : Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: isCompleted
          ? const Icon(Icons.check, size: 16, color: Color(0xFF0A7B44))
          : (isActive 
              ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) 
              : null),
    );
  }

  Widget _buildLine({required bool isCompleted}) {
    return Container(
      width: 40,
      height: 2,
      color: isCompleted ? Colors.white : Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildStep1() {
    final isUrdu = ref.watch(localeProvider);
    return Column(
      key: const ValueKey('step1'),
      children: [
        _buildSectionCard(
          title: AppStrings.get(isUrdu, 'personal_information'),
          icon: Icons.person_rounded,
          badgeText: 'All fields are required',
          children: [
            RahbarTextField(
              controller: _fullNameCtrl,
              label: 'Full Name',
              hint: 'Enter your full name',
              prefixIcon: Icons.person_outline_rounded,
              errorText: _fullNameError,
              onChanged: (_) => _fullNameError != null
                  ? setState(() => _fullNameError = null)
                  : null,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            RahbarTextField(
              controller: _usernameCtrl,
              label: 'Username',
              hint: 'Choose a username',
              prefixIcon: Icons.alternate_email_rounded,
              errorText: _usernameError,
              onChanged: (_) => _usernameError != null
                  ? setState(() => _usernameError = null)
                  : null,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            RahbarTextField(
              controller: _cnicCtrl,
              label: 'CNIC',
              hint: 'Enter 13-digit CNIC',
              prefixIcon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              errorText: _cnicError,
              onChanged: (_) =>
                  _cnicError != null ? setState(() => _cnicError = null) : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final isUrdu = ref.watch(localeProvider);
    return Column(
      key: const ValueKey('step2'),
      children: [
        _buildSectionCard(
          title: AppStrings.get(isUrdu, 'location'),
          icon: Icons.location_on_rounded,
          badgeText: 'Required',
          children: [
            GestureDetector(
              onTap: () async {
                final result = await LocationPickerSheet.show(
                  context,
                  title: 'Choose Province',
                  items: PakistanLocationData.provinces,
                  selectedItem:
                      _provinceCtrl.text.isNotEmpty ? _provinceCtrl.text : null,
                  searchHint: 'Search...',
                );
                if (result != null && result != _provinceCtrl.text) {
                  setState(() {
                    _provinceCtrl.text = result;
                    _provinceError = null;
                    // Clear city when province changes
                    _cityCtrl.clear();
                    _cityError = null;
                  });
                }
              },
              child: AbsorbPointer(
                child: RahbarTextField(
                  controller: _provinceCtrl,
                  label: AppStrings.get(isUrdu, 'province'),
                  hint: 'Punjab',
                  prefixIcon: Icons.map_rounded,
                  errorText: _provinceError,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            GestureDetector(
              onTap: () async {
                if (_provinceCtrl.text.isEmpty) {
                  setState(
                      () => _provinceError = "Choose your province first.");
                  return;
                }
                final result = await LocationPickerSheet.show(
                  context,
                  title: 'Choose City',
                  items: PakistanLocationData.getCitiesForProvince(
                      _provinceCtrl.text),
                  selectedItem:
                      _cityCtrl.text.isNotEmpty ? _cityCtrl.text : null,
                  searchHint: 'Search city...',
                );
                if (result != null) {
                  setState(() {
                    _cityCtrl.text = result;
                    _cityError = null;
                  });
                }
              },
              child: AbsorbPointer(
                child: RahbarTextField(
                  controller: _cityCtrl,
                  label: AppStrings.get(isUrdu, 'city'),
                  hint: 'Lahore',
                  prefixIcon: Icons.location_city_rounded,
                  errorText: _cityError,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            const Divider(),
            const SizedBox(height: AppTheme.spacingSmall),
            Text('Optional details',
                style: AppTheme.titleStyle
                    .copyWith(color: AppTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: AppTheme.spacingMedium),
            RahbarTextField(
              controller: _districtCtrl,
              label: AppStrings.get(isUrdu, 'district'),
              hint: 'e.g. Lahore',
              prefixIcon: Icons.my_location_rounded,
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            RahbarTextField(
              controller: _addressCtrl,
              label: AppStrings.get(isUrdu, 'address'),
              hint: 'e.g. Model Town',
              prefixIcon: Icons.home_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required String badgeText,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusLg),
        boxShadow: AppTheme.premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              children: [
                Icon(icon, color: AppTheme.pakistanGreen),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: AppTheme.titleStyle)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.pakistanGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 12, color: AppTheme.pakistanGreen),
                      const SizedBox(width: 4),
                      Text(badgeText,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.pakistanGreen,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}
