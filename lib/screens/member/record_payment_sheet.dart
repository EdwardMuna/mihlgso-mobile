import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/member_providers.dart';
import '../../widgets/state_views.dart';

class RecordPaymentSheet extends ConsumerStatefulWidget {
  const RecordPaymentSheet({super.key, this.initialContributionTypeId});

  /// Pre-selects a contribution type (e.g. tapping an unpaid dues card on
  /// the dashboard) instead of leaving the dropdown empty.
  final int? initialContributionTypeId;

  @override
  ConsumerState<RecordPaymentSheet> createState() => _RecordPaymentSheetState();
}

class _RecordPaymentSheetState extends ConsumerState<RecordPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountPaidController = TextEditingController();
  final _referenceController = TextEditingController();
  int? _contributionTypeId;
  double _amountDue = 0;
  String _paymentName = '';
  DateTime _paymentDate = DateTime.now();
  bool _submitting = false;
  bool _prefilled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _contributionTypeId = widget.initialContributionTypeId;
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _contributionTypeId == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ref.read(memberServiceProvider).recordPayment(
            contributionTypeId: _contributionTypeId!,
            paymentName: _paymentName,
            amountDue: _amountDue,
            amountPaid: double.parse(_amountPaidController.text),
            paymentDate: _paymentDate,
            reference: _referenceController.text.trim().isEmpty ? null : _referenceController.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(contributionTypesProvider);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
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
                  Text(strings.recordPayment, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  typesAsync.when(
                    loading: () => const LoadingView(),
                    error: (e, _) => ErrorRetryView(
                      message: e.toString(),
                      onRetry: () => ref.invalidate(contributionTypesProvider),
                    ),
                    data: (types) {
                      if (!_prefilled && _contributionTypeId != null) {
                        final preselected = types.where((t) => t.id == _contributionTypeId);
                        if (preselected.isNotEmpty) {
                          _amountDue = preselected.first.amount;
                          _paymentName = preselected.first.name;
                        }
                        _prefilled = true;
                      }
                      return DropdownButtonFormField<int>(
                        initialValue: _contributionTypeId,
                        decoration: InputDecoration(labelText: strings.contributionType),
                        items: types
                            .map((t) => DropdownMenuItem(value: t.id, child: Text('${t.name} (TSh ${t.amount.toStringAsFixed(0)})')))
                            .toList(),
                        validator: (v) => v == null ? strings.selectContributionType : null,
                        onChanged: (id) {
                          final type = types.firstWhere((t) => t.id == id);
                          setState(() {
                            _contributionTypeId = id;
                            _amountDue = type.amount;
                            _paymentName = type.name;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _amountPaidController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: strings.amountPaid),
                    validator: (v) {
                      final n = double.tryParse(v ?? '');
                      if (n == null || n < 0) return strings.enterValidAmount;
                      if (n > _amountDue) return strings.cannotExceedAmountDue(_amountDue.toStringAsFixed(0));
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _referenceController,
                    decoration: InputDecoration(labelText: strings.referenceOptional),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(strings.paymentDate),
                    subtitle: Text('${_paymentDate.year}-${_paymentDate.month.toString().padLeft(2, '0')}-${_paymentDate.day.toString().padLeft(2, '0')}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _paymentDate = picked);
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
                        : Text(strings.submit),
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
