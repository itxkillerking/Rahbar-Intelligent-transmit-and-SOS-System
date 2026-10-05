import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/core/theme/app_theme.dart';
import 'package:rahbar/domain/models/auth/auth_models.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_primary_button.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_text_field.dart';
import 'package:rahbar/core/data/pakistan_locations.dart';
import 'package:rahbar/presentation/shared/widgets/location_picker_sheet.dart';
import 'package:rahbar/presentation/shared/widgets/rahbar_skeleton.dart';
import 'package:rahbar/application/locale_controller.dart';
import 'package:rahbar/application/profile/local_avatar_provider.dart';
import 'package:rahbar/presentation/shared/components/authenticated_drawer.dart';
import 'package:rahbar/presentation/shared/components/rahbar_menu_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditing = false;
  
  // Controllers for edit mode
  late TextEditingController _fullNameCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _cnicCtrl;
  late TextEditingController _provinceCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _districtCtrl;
  late TextEditingController _addressCtrl;

  // New controllers for Bug 3
  late TextEditingController _emailCtrl;
  late TextEditingController _dateOfBirthCtrl;
  late TextEditingController _emergencyContactNumberCtrl;
  late TextEditingController _emergencyContactRelationshipCtrl;
  late TextEditingController _bloodGroupCtrl;
  late TextEditingController _professionCtrl;
  late TextEditingController _instituteOrganizationCtrl;
  late TextEditingController _medicalConditionsCtrl;
  late TextEditingController _disabilityCtrl;
  late TextEditingController _genderCtrl;
  
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authControllerProvider).profile;
    _initControllers(profile);
    
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authControllerProvider.notifier).loadProfile();
      });
    }
  }
  
  void _initControllers(UserProfile? profile) {
    _fullNameCtrl = TextEditingController(text: profile?.fullName ?? '');
    _usernameCtrl = TextEditingController(text: profile?.username ?? '');
    _cnicCtrl = TextEditingController(text: _maskCnic(profile?.cnic));
    _provinceCtrl = TextEditingController(text: profile?.province ?? '');
    _cityCtrl = TextEditingController(text: profile?.city ?? '');
    _districtCtrl = TextEditingController(text: profile?.district ?? '');
    _addressCtrl = TextEditingController(text: profile?.address ?? '');
    
    _emailCtrl = TextEditingController(text: profile?.email ?? '');
    _dateOfBirthCtrl = TextEditingController(text: profile?.dateOfBirth ?? '');
    _emergencyContactNumberCtrl = TextEditingController(text: profile?.emergencyContactNumber ?? '');
    _emergencyContactRelationshipCtrl = TextEditingController(text: profile?.emergencyContactRelationship ?? '');
    _bloodGroupCtrl = TextEditingController(text: profile?.bloodGroup ?? '');
    _professionCtrl = TextEditingController(text: profile?.profession ?? '');
    _instituteOrganizationCtrl = TextEditingController(text: profile?.instituteOrganization ?? '');
    _medicalConditionsCtrl = TextEditingController(text: profile?.medicalConditions ?? '');
    _disabilityCtrl = TextEditingController(text: profile?.disability ?? '');
    _genderCtrl = TextEditingController(text: profile?.gender ?? '');
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
    _emailCtrl.dispose();
    _dateOfBirthCtrl.dispose();
    _emergencyContactNumberCtrl.dispose();
    _emergencyContactRelationshipCtrl.dispose();
    _bloodGroupCtrl.dispose();
    _professionCtrl.dispose();
    _instituteOrganizationCtrl.dispose();
    _medicalConditionsCtrl.dispose();
    _disabilityCtrl.dispose();
    _genderCtrl.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Save changes
      FocusScope.of(context).unfocus();
      final payload = <String, dynamic>{};
      
      final name = _fullNameCtrl.text.trim();
      if (name.isNotEmpty) payload['full_name'] = name;
      
      final uname = _usernameCtrl.text.trim();
      if (uname.isNotEmpty) payload['username'] = uname;
      
      final cnic = _cnicCtrl.text.trim();
      if (cnic.isNotEmpty && !cnic.contains('*')) {
        payload['cnic'] = cnic;
      }
      
      final prov = _provinceCtrl.text.trim();
      if (prov.isNotEmpty) payload['province'] = prov;
      
      final city = _cityCtrl.text.trim();
      if (city.isNotEmpty) payload['city'] = city;
      
      if (_districtCtrl.text.trim().isNotEmpty) payload['district'] = _districtCtrl.text.trim();
      if (_addressCtrl.text.trim().isNotEmpty) payload['address'] = _addressCtrl.text.trim();
      
      final email = _emailCtrl.text.trim();
      if (email.isNotEmpty) payload['email'] = email;
      
      final dob = _dateOfBirthCtrl.text.trim();
      if (dob.isNotEmpty) payload['date_of_birth'] = dob;
      
      final ecNum = _emergencyContactNumberCtrl.text.trim();
      if (ecNum.isNotEmpty) payload['emergency_contact_number'] = ecNum;
      
      final ecRel = _emergencyContactRelationshipCtrl.text.trim();
      if (ecRel.isNotEmpty) payload['emergency_contact_relationship'] = ecRel;
      
      final bg = _bloodGroupCtrl.text.trim();
      if (bg.isNotEmpty) payload['blood_group'] = bg;
      
      final prof = _professionCtrl.text.trim();
      if (prof.isNotEmpty) payload['profession'] = prof;
      
      final inst = _instituteOrganizationCtrl.text.trim();
      if (inst.isNotEmpty) payload['institute_organization'] = inst;
      
      final med = _medicalConditionsCtrl.text.trim();
      if (med.isNotEmpty) payload['medical_conditions'] = med;
      
      final dis = _disabilityCtrl.text.trim();
      if (dis.isNotEmpty) payload['disability'] = dis;
      
      final gen = _genderCtrl.text.trim();
      if (gen.isNotEmpty) payload['gender'] = gen;

      if (payload.isNotEmpty) {
        ref.read(authControllerProvider.notifier).submitProfile(payload).then((_) {
          if (mounted && ref.read(authControllerProvider).errorMessage == null) {
            setState(() => _isEditing = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppTheme.pakistanGreen),
            );
          }
        });
      } else {
        setState(() => _isEditing = false);
      }
    } else {
      setState(() => _isEditing = true);
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppTheme.spacingMedium),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: AppTheme.pakistanGreen),
              title: const Text('Take photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppTheme.pakistanGreen),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor),
              title: const Text('Remove current photo', style: TextStyle(color: AppTheme.errorColor)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(localAvatarProvider.notifier).removeAvatar();
                setState(() => _selectedImage = null);
              },
            ),
            const SizedBox(height: AppTheme.spacingMedium),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() {
          _selectedImage = File(picked.path);
        });
        ref.read(localAvatarProvider.notifier).updateAvatar(picked.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated locally. Online sync coming soon.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open camera/gallery. Check permissions.'), backgroundColor: AppTheme.errorColor),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final profile = authState.profile;

    ref.listen(authControllerProvider, (previous, next) {
      if (previous?.profile == null && next.profile != null && !_isEditing) {
        _fullNameCtrl.text = next.profile!.fullName ?? '';
        _usernameCtrl.text = next.profile!.username ?? '';
        _provinceCtrl.text = next.profile!.province ?? '';
        _cityCtrl.text = next.profile!.city ?? '';
        _districtCtrl.text = next.profile!.district ?? '';
        _addressCtrl.text = next.profile!.address ?? '';
      }
    });

    Widget bodyContent;

    if (profile != null) {
      bodyContent = _buildProfileContent(profile, authState, key: const ValueKey('content'));
    } else if (authState.isProfileLoading) {
      bodyContent = _buildSkeleton(key: const ValueKey('skeleton'));
    } else if (authState.profileError != null) {
      bodyContent = _buildErrorState(authState.profileError!, key: const ValueKey('error'));
    } else {
      // Fallback if null and no error/loading
      bodyContent = _buildSkeleton(key: const ValueKey('skeleton'));
    }

    return Scaffold(
      drawer: const AuthenticatedDrawer(),
      appBar: AppBar(
        leadingWidth: 100,
        leading: Row(
          children: [
            const SizedBox(width: 8),
            Builder(
              builder: (ctx) => RahbarMenuButton(
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const BackButton(),
          ],
        ),
        title: Text(_isEditing ? AppStrings.get(ref.watch(localeProvider), 'edit_profile') : AppStrings.get(ref.watch(localeProvider), 'my_profile')),
        actions: [
          if (profile != null)
            TextButton(
              onPressed: _toggleEdit,
              child: Text(
                _isEditing ? 'Save' : 'Edit',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.pakistanGreen),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: bodyContent,
      ),
    );
  }

  Widget _buildSkeleton({Key? key}) {
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        children: [
          const Center(child: RahbarSkeleton(width: 100, height: 100, borderRadius: 50)),
          const SizedBox(height: AppTheme.spacingMedium),
          const RahbarSkeleton(width: 150, height: 24),
          const SizedBox(height: 8),
          const RahbarSkeleton(width: 100, height: 16),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildSkeletonSection(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildSkeletonSection(),
        ],
      ),
    );
  }

  Widget _buildSkeletonSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          RahbarSkeleton(width: 120, height: 20),
          SizedBox(height: AppTheme.spacingMedium),
          RahbarSkeleton(width: double.infinity, height: 16),
          SizedBox(height: 12),
          RahbarSkeleton(width: double.infinity, height: 16),
          SizedBox(height: 12),
          RahbarSkeleton(width: double.infinity, height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, {Key? key}) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.errorColor, size: 48),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(error, style: AppTheme.bodyStyle, textAlign: TextAlign.center),
            const SizedBox(height: AppTheme.spacingLarge),
            RahbarPrimaryButton(
              label: AppStrings.get(ref.watch(localeProvider), 'retry'),
              onPressed: () => ref.read(authControllerProvider.notifier).loadProfile(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile, AuthStateData authState, {Key? key}) {
    final isUrdu = ref.watch(localeProvider);
    
    return SingleChildScrollView(
      key: key,
      padding: const EdgeInsets.all(AppTheme.spacingLarge),
      physics: const BouncingScrollPhysics(),
      child: Column(
          children: [
            // Avatar Section
            Consumer(
              builder: (context, ref, child) {
                final avatarPath = ref.watch(localAvatarProvider);
                return Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.lightGreenSurface,
                        backgroundImage: _selectedImage != null 
                            ? FileImage(_selectedImage!) 
                            : (avatarPath != null ? FileImage(File(avatarPath)) : null) as ImageProvider?,
                        child: (_selectedImage == null && avatarPath == null) ? const Icon(Icons.person, size: 50, color: AppTheme.pakistanGreen) : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showPhotoOptions,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.pakistanGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacingMedium),
            Text(profile.fullName ?? 'User', style: AppTheme.headingStyle),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_rounded, color: AppTheme.safeColor, size: 16),
                const SizedBox(width: 4),
                Text(authState.phoneNumber ?? '', style: AppTheme.captionStyle.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            if (authState.errorMessage != null && _isEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(authState.errorMessage!, style: const TextStyle(color: AppTheme.errorColor)),
              ),
            
            // Info Sections
            _buildSection(
              title: AppStrings.get(isUrdu, 'personal_information'),
              children: _isEditing 
                ? [
                    RahbarTextField(controller: _fullNameCtrl, label: 'Full Name', hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _usernameCtrl, label: 'Username', hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _cnicCtrl, label: 'CNIC', hint: 'Enter 13 digit CNIC to change'),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _emailCtrl, label: 'Email', hint: ''),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final result = await LocationPickerSheet.show(
                          context,
                          title: 'Select Gender',
                          items: [
                            AppStrings.get(isUrdu, 'male'),
                            AppStrings.get(isUrdu, 'female'),
                            AppStrings.get(isUrdu, 'other'),
                            AppStrings.get(isUrdu, 'prefer_not_to_say')
                          ],
                          selectedItem: _genderCtrl.text.isNotEmpty ? _genderCtrl.text : null,
                          searchHint: 'Search...',
                        );
                        if (result != null) {
                          setState(() {
                            _genderCtrl.text = result;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: RahbarTextField(
                          controller: _genderCtrl,
                          label: AppStrings.get(isUrdu, 'gender'),
                          hint: 'Select Gender',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _dateOfBirthCtrl, label: 'Date of Birth', hint: 'YYYY-MM-DD'),
                  ]
                : [
                    _InfoRow(label: 'Full Name', value: profile.fullName ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: 'Username', value: profile.username ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: 'CNIC', value: _maskCnic(profile.cnic)),
                    _InfoRow(label: 'Email', value: profile.email ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'gender'), value: profile.gender ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: 'Date of Birth', value: profile.dateOfBirth ?? AppStrings.get(isUrdu, 'not_provided')),
                  ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            _buildSection(
              title: AppStrings.get(isUrdu, 'location'),
              children: _isEditing 
                ? [
                    GestureDetector(
                      onTap: () async {
                        final result = await LocationPickerSheet.show(
                          context,
                          title: 'Choose Province',
                          items: PakistanLocationData.provinces,
                          selectedItem: _provinceCtrl.text.isNotEmpty ? _provinceCtrl.text : null,
                          searchHint: 'Search...',
                        );
                        if (result != null && result != _provinceCtrl.text) {
                          setState(() {
                            _provinceCtrl.text = result;
                            _cityCtrl.clear();
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: RahbarTextField(controller: _provinceCtrl, label: AppStrings.get(isUrdu, 'province'), hint: ''),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        if (_provinceCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Choose your province first'), backgroundColor: AppTheme.errorColor),
                          );
                          return;
                        }
                        final result = await LocationPickerSheet.show(
                          context,
                          title: 'Choose City',
                          items: PakistanLocationData.getCitiesForProvince(_provinceCtrl.text),
                          selectedItem: _cityCtrl.text.isNotEmpty ? _cityCtrl.text : null,
                          searchHint: 'Search city...',
                        );
                        if (result != null) {
                          setState(() {
                            _cityCtrl.text = result;
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: RahbarTextField(controller: _cityCtrl, label: AppStrings.get(isUrdu, 'city'), hint: ''),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _districtCtrl, label: AppStrings.get(isUrdu, 'district'), hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _addressCtrl, label: AppStrings.get(isUrdu, 'address'), hint: ''),
                  ]
                : [
                    _InfoRow(label: AppStrings.get(isUrdu, 'province'), value: profile.province ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'city'), value: profile.city ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'district'), value: profile.district ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'address'), value: profile.address ?? AppStrings.get(isUrdu, 'not_provided')),
                  ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            _buildSection(
              title: AppStrings.get(isUrdu, 'emergency_contact'),
              children: _isEditing
                ? [
                    RahbarTextField(controller: _emergencyContactNumberCtrl, label: 'Emergency Contact Number', hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _emergencyContactRelationshipCtrl, label: 'Relationship', hint: ''),
                  ]
                : [
                    _InfoRow(label: 'Emergency Contact Number', value: profile.emergencyContactNumber ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: 'Relationship', value: profile.emergencyContactRelationship ?? AppStrings.get(isUrdu, 'not_provided')),
                  ],
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildSection(
              title: AppStrings.get(isUrdu, 'health_information'),
              children: _isEditing
                ? [
                    RahbarTextField(controller: _bloodGroupCtrl, label: AppStrings.get(isUrdu, 'blood_group'), hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _medicalConditionsCtrl, label: AppStrings.get(isUrdu, 'medical_conditions'), hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _disabilityCtrl, label: AppStrings.get(isUrdu, 'disability'), hint: ''),
                  ]
                : [
                    _InfoRow(label: AppStrings.get(isUrdu, 'blood_group'), value: profile.bloodGroup ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'medical_conditions'), value: profile.medicalConditions ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'disability'), value: profile.disability ?? AppStrings.get(isUrdu, 'not_provided')),
                  ],
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            _buildSection(
              title: AppStrings.get(isUrdu, 'professional_information'),
              children: _isEditing
                ? [
                    RahbarTextField(controller: _professionCtrl, label: AppStrings.get(isUrdu, 'profession'), hint: ''),
                    const SizedBox(height: 12),
                    RahbarTextField(controller: _instituteOrganizationCtrl, label: AppStrings.get(isUrdu, 'institute_organization'), hint: ''),
                  ]
                : [
                    _InfoRow(label: AppStrings.get(isUrdu, 'profession'), value: profile.profession ?? AppStrings.get(isUrdu, 'not_provided')),
                    _InfoRow(label: AppStrings.get(isUrdu, 'institute_organization'), value: profile.instituteOrganization ?? AppStrings.get(isUrdu, 'not_provided')),
                  ],
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: RahbarPrimaryButton(
                  label: AppStrings.get(isUrdu, 'save_changes'),
                  onPressed: _toggleEdit,
                ),
              ),
          ],
        ),
    );
  }

  String _maskCnic(String? cnic) {
    if (cnic == null || cnic.isEmpty) return 'Not provided';
    // e.g. 12345-6789012-3 -> 12345-*******-3
    if (cnic.length >= 13) {
      if (cnic.contains('-')) {
        final parts = cnic.split('-');
        if (parts.length == 3) {
          return '${parts[0]}-*******-${parts[2]}';
        }
      }
      // If no dashes but 13 chars
      return '${cnic.substring(0, 5)}-*******-${cnic.substring(12)}';
    }
    return '***'; // Fallback
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.cornerRadiusMd),
        boxShadow: AppTheme.premiumShadow,
        border: Border.all(color: AppTheme.textSecondary.withValues(alpha: 0.1)),
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppTheme.titleStyle.copyWith(color: AppTheme.pakistanGreen)),
          const SizedBox(height: AppTheme.spacingMedium),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.captionStyle),
          const SizedBox(height: 2),
          Text(value, style: AppTheme.bodyStyle),
        ],
      ),
    );
  }
}
