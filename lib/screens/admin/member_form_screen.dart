import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/admin_member.dart';
import '../../providers/admin_providers.dart';
import 'member_detail_screen.dart' show memberAvatarImage;

const _employmentStatusOptions = ['EMPLOYED', 'UNEMPLOYED', 'SELF_EMPLOYED', 'RETIRED'];
const _educationLevelOptions = ["Diploma", "Bachelor's Degree", "Master's Degree", 'PhD', 'Prof'];
const _genderOptions = ['MALE', 'FEMALE'];

String _employmentStatusLabel(String value, AppStrings strings) {
  switch (value) {
    case 'EMPLOYED':
      return strings.employmentStatusEmployed;
    case 'UNEMPLOYED':
      return strings.employmentStatusUnemployed;
    case 'SELF_EMPLOYED':
      return strings.employmentStatusSelfEmployed;
    case 'RETIRED':
      return strings.employmentStatusRetired;
    default:
      return value;
  }
}

String _educationLevelDisplayLabel(String value, AppStrings strings) {
  switch (value) {
    case 'Diploma':
      return strings.diploma;
    case "Bachelor's Degree":
      return strings.bachelorsDegree;
    case "Master's Degree":
      return strings.mastersDegree;
    case 'PhD':
      return strings.phd;
    case 'Prof':
      return strings.prof;
    default:
      return value;
  }
}

/// Add/edit member form — mirrors the website's MemberForm.tsx field order
/// and validation. Pass [existing] to edit, or omit it to create a new member.
class MemberFormScreen extends ConsumerStatefulWidget {
  const MemberFormScreen({super.key, this.existing});
  final AdminMember? existing;

  bool get isEdit => existing != null;

  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.existing?.name);
  late final _emailController = TextEditingController(text: widget.existing?.email);
  late final _phoneController = TextEditingController(text: widget.existing?.phone);
  late final _institutionController = TextEditingController(text: widget.existing?.institution);
  late final _graduatedYearController = TextEditingController(text: widget.existing?.graduatedYear?.toString());
  late final _postalAddressController = TextEditingController(text: widget.existing?.postalAddress);
  late final _currentResidentialController = TextEditingController(text: widget.existing?.currentResidential);
  late final _academicDisciplineController = TextEditingController(text: widget.existing?.academicDiscipline);
  late final _employerController = TextEditingController(text: widget.existing?.employer);
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _employmentStatus;
  String? _educationLevel;
  String? _gender;
  late String _status = widget.existing?.status ?? 'ACTIVE';
  late bool _isDonor = widget.existing?.isDonor ?? false;
  XFile? _newPhoto;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _employmentStatus = widget.existing?.employmentStatus;
    _educationLevel = widget.existing?.educationLevel;
    _gender = widget.existing?.gender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    _graduatedYearController.dispose();
    _postalAddressController.dispose();
    _currentResidentialController.dispose();
    _academicDisciplineController.dispose();
    _employerController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _newPhoto = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final service = ref.read(adminServiceProvider);
      if (widget.isEdit) {
        await service.updateMember(
          widget.existing!.id,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          status: _status,
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
          newPassword: _passwordController.text.isEmpty ? null : _passwordController.text,
        );
        if (_newPhoto != null) {
          await service.uploadMemberPhoto(widget.existing!.id, _newPhoto!.path);
        }
      } else {
        final created = await service.createMember(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
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
        if (_newPhoto != null) {
          await service.uploadMemberPhoto(created.id, _newPhoto!.path);
        }
      }
      ref.invalidate(adminMembersProvider);
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEdit ? strings.editMemberTitle : strings.addMemberTitleForm)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Builder(builder: (context) {
                  final avatarImage =
                      _newPhoto != null ? FileImage(File(_newPhoto!.path)) : memberAvatarImage(widget.existing?.photoDataUrl);
                  return Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: avatarImage,
                      child: avatarImage == null
                          ? const Icon(Icons.person_outline, size: 36)
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _newPhoto == null ? strings.tapToSetPassportPhoto : strings.newPhotoSelected,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: strings.fullName),
              validator: (v) => (v == null || v.trim().isEmpty) ? strings.nameRequired : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: strings.email),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return strings.emailRequired;
                if (!v.contains('@')) return strings.enterValidEmail;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: strings.phone)),
            const SizedBox(height: 12),
            TextFormField(controller: _institutionController, decoration: InputDecoration(labelText: strings.institution)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _graduatedYearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: strings.graduatedYearLabel),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _postalAddressController, decoration: InputDecoration(labelText: strings.postalAddress)),
            const SizedBox(height: 12),
            TextFormField(controller: _currentResidentialController, decoration: InputDecoration(labelText: strings.currentResidential)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _employmentStatus,
              decoration: InputDecoration(labelText: strings.employmentStatus),
              items: _employmentStatusOptions
                  .map((v) => DropdownMenuItem(value: v, child: Text(_employmentStatusLabel(v, strings))))
                  .toList(),
              onChanged: (v) => setState(() => _employmentStatus = v),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _academicDisciplineController, decoration: InputDecoration(labelText: strings.academicDiscipline)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _educationLevel,
              decoration: InputDecoration(labelText: strings.educationLevel),
              items: _educationLevelOptions.map((v) => DropdownMenuItem(value: v, child: Text(_educationLevelDisplayLabel(v, strings)))).toList(),
              onChanged: (v) => setState(() => _educationLevel = v),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _employerController, decoration: InputDecoration(labelText: strings.employerOffice)),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: InputDecoration(labelText: strings.gender),
              items: _genderOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            if (widget.isEdit) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(labelText: strings.accountStatus),
                items: [
                  DropdownMenuItem(value: 'ACTIVE', child: Text(strings.activeStatus)),
                  DropdownMenuItem(value: 'SUSPENDED', child: Text(strings.suspendedStatus)),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'ACTIVE'),
              ),
            ],
            const SizedBox(height: 12),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.donorLabel),
              value: _isDonor,
              onChanged: (v) => setState(() => _isDonor = v ?? false),
            ),
            const SizedBox(height: 12),
            if (widget.isEdit) ...[
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.newPasswordOptional),
                validator: (v) {
                  if (v != null && v.isNotEmpty && v.length < 8) return strings.passwordMustBeAtLeast8;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.confirmNewPassword),
                validator: (v) {
                  if (_passwordController.text.isNotEmpty && v != _passwordController.text) return strings.passwordsDoNotMatch;
                  return null;
                },
              ),
            ] else ...[
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: strings.initialPassword),
                validator: (v) {
                  if (v == null || v.length < 8) return strings.passwordMustBeAtLeast8;
                  return null;
                },
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(widget.isEdit ? strings.save : strings.registerButton),
            ),
          ],
        ),
      ),
    );
  }
}
