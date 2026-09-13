import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/core_providers.dart';

const _employmentStatuses = ['EMPLOYED', 'UNEMPLOYED', 'SELF_EMPLOYED', 'RETIRED'];
const _genders = ['MALE', 'FEMALE'];

class ApplyScreen extends ConsumerStatefulWidget {
  const ApplyScreen({super.key});

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _institutionController = TextEditingController();
  final _disciplineController = TextEditingController();
  final _yearController = TextEditingController();
  final _postalController = TextEditingController();
  final _residentialController = TextEditingController();
  final _employerController = TextEditingController();

  String _registrationType = 'STAKEHOLDER';
  String? _employmentStatus;
  String? _gender;
  String? _levelOfEducation;
  XFile? _photo;
  bool _submitting = false;
  String? _error;
  bool _submitted = false;

  bool get _isMember => _registrationType == 'MEMBER';

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _institutionController,
      _disciplineController,
      _yearController,
      _postalController,
      _residentialController,
      _employerController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _photo = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(applicationServiceProvider).submit(
            registrationType: _registrationType,
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            institution: _isMember ? _institutionController.text.trim() : null,
            academicDiscipline: _isMember ? _disciplineController.text.trim() : null,
            graduatedYear: _isMember ? _yearController.text.trim() : null,
            postalAddress: _isMember ? _postalController.text.trim() : null,
            currentResidential: _isMember ? _residentialController.text.trim() : null,
            employmentStatus: _isMember ? _employmentStatus : null,
            levelOfEducation: _isMember ? _levelOfEducation : null,
            employer: _isMember ? _employerController.text.trim() : null,
            gender: _isMember ? _gender : null,
            photoPath: _photo?.path,
          );
      if (mounted) setState(() => _submitted = true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    if (_submitted) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.applyForMembership)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                const SizedBox(height: AppSpacing.md),
                Text(
                  strings.applicationSubmittedMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(strings.back),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.applyForMembership)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl + 14,
          ),
          children: [
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'STAKEHOLDER', label: Text(strings.stakeholder)),
                ButtonSegment(value: 'MEMBER', label: Text(strings.member)),
              ],
              selected: {_registrationType},
              onSelectionChanged: (s) => setState(() => _registrationType = s.first),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: strings.fullName),
              validator: (v) => (v == null || v.trim().length < 2) ? strings.required : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: strings.email),
              validator: (v) => (v == null || !v.contains('@')) ? strings.enterValidEmail : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(labelText: strings.phoneLabel),
              validator: (v) => (v == null || v.trim().length < 8) ? strings.enterValidPhone : null,
            ),
            if (_isMember) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _institutionController,
                decoration: InputDecoration(labelText: strings.institution),
                validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _disciplineController,
                decoration: InputDecoration(labelText: strings.academicDiscipline),
                validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: strings.graduatedYear),
                validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _residentialController,
                decoration: InputDecoration(labelText: strings.currentResidentialAddress),
                validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _postalController,
                decoration: InputDecoration(labelText: strings.postalAddressOptional),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _employmentStatus,
                decoration: InputDecoration(labelText: strings.employmentStatus),
                items: _employmentStatuses.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                validator: (v) => v == null ? strings.required : null,
                onChanged: (v) => setState(() => _employmentStatus = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: strings.levelOfEducation),
                validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
                onChanged: (v) => _levelOfEducation = v,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _employerController,
                decoration: InputDecoration(labelText: strings.employerOptional),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(labelText: strings.gender),
                items: _genders.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                validator: (v) => v == null ? strings.required : null,
                onChanged: (v) => setState(() => _gender = v),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(_photo == null ? strings.addPassportPhotoOptional : strings.photoSelected),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(strings.submitApplication),
            ),
          ],
        ),
      ),
    );
  }
}
