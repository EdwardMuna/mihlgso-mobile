import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/donation.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_providers.dart';

/// Record a new donation, or edit one the signed-in member already recorded
/// (pass [existing]) — editing is only allowed while it's still PENDING,
/// enforced both here (read-only banner) and server-side.
class RecordDonationSheet extends ConsumerStatefulWidget {
  const RecordDonationSheet({super.key, this.existing});

  final Donation? existing;

  bool get isEdit => existing != null;

  @override
  ConsumerState<RecordDonationSheet> createState() => _RecordDonationSheetState();
}

class _RecordDonationSheetState extends ConsumerState<RecordDonationSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _amountController = TextEditingController(text: widget.existing?.amount.toString());
  late final _purposeController = TextEditingController(text: widget.existing?.purpose);
  late final _referenceController = TextEditingController(text: widget.existing?.reference);
  late final _notesController = TextEditingController(text: widget.existing?.notes);
  late DateTime _donatedAt = widget.existing?.donatedAt ?? DateTime.now();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _referenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(authControllerProvider).valueOrNull;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final service = ref.read(memberServiceProvider);
      if (widget.isEdit) {
        await service.updateDonation(
          widget.existing!.id,
          donorName: widget.existing!.donorName,
          amount: double.parse(_amountController.text),
          donatedAt: _donatedAt,
          donorEmail: widget.existing!.donorEmail,
          donorPhone: widget.existing!.donorPhone,
          purpose: _purposeController.text.trim().isEmpty ? null : _purposeController.text.trim(),
          reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      } else {
        await service.recordDonation(
          donorName: user?.name ?? 'Member',
          amount: double.parse(_amountController.text),
          donatedAt: _donatedAt,
          purpose: _purposeController.text.trim().isEmpty ? null : _purposeController.text.trim(),
          reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          final strings = AppStrings.of(context);
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
            child: Form(
              key: _formKey,
              child: ListView(
                controller: scrollController,
                children: [
                  Text(widget.isEdit ? strings.editDonation : strings.recordDonation, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: strings.amount),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n <= 0) return strings.enterValidAmount;
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _purposeController,
                    decoration: InputDecoration(labelText: strings.purposeOptional),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _referenceController,
                    decoration: InputDecoration(labelText: strings.referenceOptional),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(labelText: strings.notesOptional),
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.donationDate),
                    subtitle: Text('${_donatedAt.year}-${_donatedAt.month.toString().padLeft(2, '0')}-${_donatedAt.day.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _donatedAt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _donatedAt = picked);
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(widget.isEdit ? strings.saveChanges : strings.submit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
