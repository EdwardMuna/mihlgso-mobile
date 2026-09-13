import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_providers.dart';
import '../admin/member_detail_screen.dart' show employmentStatusLabel, memberAvatarImage;

const _employmentStatusOptions = ['EMPLOYED', 'UNEMPLOYED', 'SELF_EMPLOYED', 'RETIRED'];
const _educationLevelOptions = ["Diploma", "Bachelor's Degree", "Master's Degree", 'PhD', 'Prof'];
const _genderOptions = ['MALE', 'FEMALE'];

/// "My profile" — mirrors the website's member profile page: an editable
/// details form (PATCH /api/me, plus a separate photo upload) and a
/// change-password card, both fetched from and saved to the signed-in user.
class MemberProfileScreen extends ConsumerStatefulWidget {
  const MemberProfileScreen({super.key});

  @override
  ConsumerState<MemberProfileScreen> createState() => _MemberProfileScreenState();
}

class _MemberProfileScreenState extends ConsumerState<MemberProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _institutionController = TextEditingController();
  final _academicDisciplineController = TextEditingController();
  final _graduatedYearController = TextEditingController();
  final _postalAddressController = TextEditingController();
  final _currentResidentialController = TextEditingController();
  final _employerController = TextEditingController();

  String? _employmentStatus;
  String? _educationLevel;
  String? _gender;
  bool _isDonor = false;
  XFile? _newPhoto;

  bool _initialized = false;
  bool _savingProfile = false;
  String? _profileError;

  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _currentPasswordVisible = false;
  bool _newPasswordVisible = false;
  bool _changingPassword = false;
  String? _passwordError;

  void _populateFrom(AppUser user) {
    _phoneController.text = user.phone ?? '';
    _institutionController.text = user.institution ?? '';
    _academicDisciplineController.text = user.academicDiscipline ?? '';
    _graduatedYearController.text = user.graduatedYear?.toString() ?? '';
    _postalAddressController.text = user.postalAddress ?? '';
    _currentResidentialController.text = user.currentResidential ?? '';
    _employerController.text = user.employer ?? '';
    _employmentStatus = user.employmentStatus;
    _educationLevel = _educationLevelOptions.firstWhere(
      (o) => o.toLowerCase() == user.educationLevel?.toLowerCase(),
      orElse: () => '',
    );
    if (_educationLevel!.isEmpty) _educationLevel = null;
    _gender = user.gender;
    _isDonor = user.isDonor;
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _institutionController.dispose();
    _academicDisciplineController.dispose();
    _graduatedYearController.dispose();
    _postalAddressController.dispose();
    _currentResidentialController.dispose();
    _employerController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _newPhoto = picked);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _savingProfile = true;
      _profileError = null;
    });
    try {
      final service = ref.read(memberServiceProvider);
      if (_newPhoto != null) {
        await service.uploadPhoto(_newPhoto!.path);
      }
      await service.updateProfile(
        phone: _phoneController.text.trim(),
        institution: _institutionController.text.trim(),
        academicDiscipline: _academicDisciplineController.text.trim(),
        graduatedYear: _graduatedYearController.text.trim(),
        postalAddress: _postalAddressController.text.trim(),
        currentResidential: _currentResidentialController.text.trim(),
        employmentStatus: _employmentStatus,
        educationLevel: _educationLevel,
        employer: _employerController.text.trim(),
        gender: _gender,
        isDonor: _isDonor,
      );
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (mounted) {
        setState(() => _newPhoto = null);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).profileSaved)));
      }
    } on ApiException catch (e) {
      setState(() => _profileError = e.message);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    setState(() {
      _changingPassword = true;
      _passwordError = null;
    });
    try {
      await ref.read(memberServiceProvider).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      _currentPasswordController.clear();
      _newPasswordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).passwordUpdated)));
      }
    } on ApiException catch (e) {
      setState(() => _passwordError = e.message);
    } finally {
      if (mounted) setState(() => _changingPassword = false);
    }
  }

  Widget _sectionHeader(BuildContext context, IconData icon, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.gradientBlue.withValues(alpha: 0.06),
            AppColors.gradientGreen.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    if (user != null && !_initialized) {
      _initialized = true;
      _populateFrom(user);
    }

    final avatarImage = memberAvatarImage(user?.photoDataUrl);
    final strings = AppStrings.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 41,
                        backgroundImage: avatarImage,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: avatarImage == null
                            ? Text(
                                (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.w600),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 13,
                          backgroundColor: AppColors.accent,
                          child: const Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                user?.name ?? '',
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                user?.email ?? '',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                _newPhoto == null ? strings.tapPhotoToChange : strings.newPhotoSelected,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader(context, Icons.badge_outlined, strings.contactAndAddress),
              const SizedBox(height: AppSpacing.sm),
              _card(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: strings.phone, prefixIcon: const Icon(Icons.phone_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _postalAddressController,
                      decoration: InputDecoration(labelText: strings.postalAddress, prefixIcon: const Icon(Icons.markunread_mailbox_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _currentResidentialController,
                      decoration: InputDecoration(labelText: strings.currentResidential, prefixIcon: const Icon(Icons.home_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: InputDecoration(labelText: strings.gender, prefixIcon: const Icon(Icons.wc_outlined)),
                      items: _genderOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionHeader(context, Icons.school_outlined, strings.education),
              const SizedBox(height: AppSpacing.sm),
              _card(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _institutionController,
                      decoration: InputDecoration(labelText: strings.institution, prefixIcon: const Icon(Icons.account_balance_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _academicDisciplineController,
                      decoration: InputDecoration(labelText: strings.academicDiscipline, prefixIcon: const Icon(Icons.menu_book_outlined)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _graduatedYearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: strings.graduatedYear, prefixIcon: const Icon(Icons.calendar_today_outlined)),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _educationLevel,
                      decoration: InputDecoration(labelText: strings.educationLevel, prefixIcon: const Icon(Icons.school_outlined)),
                      items: _educationLevelOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                      onChanged: (v) => setState(() => _educationLevel = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              _sectionHeader(context, Icons.work_outline, strings.employment),
              const SizedBox(height: AppSpacing.sm),
              _card(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _employmentStatus,
                      decoration: InputDecoration(labelText: strings.employmentStatus, prefixIcon: const Icon(Icons.work_outline)),
                      items: _employmentStatusOptions
                          .map((v) => DropdownMenuItem(value: v, child: Text(employmentStatusLabel(v, strings))))
                          .toList(),
                      onChanged: (v) => setState(() => _employmentStatus = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _employerController,
                      decoration: InputDecoration(labelText: strings.employerOffice, prefixIcon: const Icon(Icons.apartment_outlined)),
                    ),
                    const SizedBox(height: 4),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(strings.registerAsDonor),
                      value: _isDonor,
                      onChanged: (v) => setState(() => _isDonor = v ?? false),
                    ),
                  ],
                ),
              ),
              if (_profileError != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, size: 18, color: Theme.of(context).colorScheme.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _profileError!,
                          style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: _savingProfile ? null : _saveProfile,
                icon: _savingProfile
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_savingProfile ? strings.savingEllipsis : strings.saveProfile),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeader(context, Icons.lock_outline, strings.changePassword),
        const SizedBox(height: AppSpacing.sm),
        _card(
          child: Form(
            key: _passwordFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: !_currentPasswordVisible,
                  decoration: InputDecoration(
                    labelText: strings.currentPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_currentPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _currentPasswordVisible = !_currentPasswordVisible),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? strings.required : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !_newPasswordVisible,
                  decoration: InputDecoration(
                    labelText: strings.newPasswordMinChars,
                    prefixIcon: const Icon(Icons.lock_reset_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_newPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _newPasswordVisible = !_newPasswordVisible),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 8) ? strings.passwordMustBeAtLeast8 : null,
                ),
                if (_passwordError != null) ...[
                  const SizedBox(height: 8),
                  Text(_passwordError!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: _changingPassword ? null : _changePassword,
                  icon: _changingPassword
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.key_outlined),
                  label: Text(_changingPassword ? strings.updatingEllipsis : strings.updatePassword),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout),
          label: Text(strings.signOut),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: Theme.of(context).colorScheme.error,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    );
  }
}
