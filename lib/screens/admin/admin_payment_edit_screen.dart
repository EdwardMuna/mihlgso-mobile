import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/payment.dart';
import '../../providers/admin_providers.dart';

/// Admin "edit payment" screen. The backend's PATCH /api/admin/payments/:id
/// only accepts an approvalStatus change — there is no endpoint yet to edit
/// a payment's amount, date, member, or contribution type. Until that lands,
/// this screen shows the full record and exposes the approve/reject action
/// that IS supported, and says so clearly for anything it doesn't support.
class AdminPaymentEditScreen extends ConsumerStatefulWidget {
  const AdminPaymentEditScreen({super.key, required this.payment});
  final Payment payment;

  @override
  ConsumerState<AdminPaymentEditScreen> createState() => _AdminPaymentEditScreenState();
}

class _AdminPaymentEditScreenState extends ConsumerState<AdminPaymentEditScreen> {
  late Payment _payment = widget.payment;
  bool _submitting = false;
  String? _error;

  Future<void> _setApproval(String action) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final service = ref.read(adminServiceProvider);
      final updated = action == 'approve' ? await service.approvePayment(_payment.id) : await service.rejectPayment(_payment.id);
      ref.invalidate(adminPaymentsProvider);
      setState(() => _payment = updated);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final dateFmt = DateFormat.yMMMd();
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final p = _payment;

    return Scaffold(
      appBar: AppBar(title: Text(strings.editPaymentTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
        children: [
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(strings.paymentEditLimitationMessage),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _row(context, strings.paymentNameLabel, p.paymentName),
          if (p.memberName != null) _row(context, strings.memberLabel, '${p.memberName}${p.memberEmail != null ? ' (${p.memberEmail})' : ''}'),
          if (p.contributionType != null) _row(context, strings.contributionType, p.contributionType!.name),
          _row(context, strings.amountDueLabel, currency.format(p.amountDue)),
          _row(context, strings.amountPaid, currency.format(p.amountPaid)),
          _row(context, strings.remainingLabel, currency.format(p.amountRemaining)),
          _row(context, strings.paymentDate, dateFmt.format(p.paymentDate)),
          if (p.reference != null && p.reference!.isNotEmpty) _row(context, strings.referenceLabel, p.reference!),
          if (p.notes != null && p.notes!.isNotEmpty) _row(context, strings.notesLabel, p.notes!),
          _row(context, strings.status, p.status.name.toUpperCase()),
          _row(context, strings.approvalStatusLabel, p.approvalStatus.name.toUpperCase()),
          if (p.reviewedAt != null) _row(context, strings.reviewedLabel, dateFmt.format(p.reviewedAt!)),
          if (p.createdAt != null) _row(context, strings.recordedLabel, dateFmt.format(p.createdAt!)),
          if (p.updatedAt != null) _row(context, strings.lastUpdatedLabel, dateFmt.format(p.updatedAt!)),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (p.approvalStatus == ApprovalStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _submitting ? null : () => _setApproval('reject'),
                    child: Text(strings.reject),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitting ? null : () => _setApproval('approve'),
                    child: _submitting
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(strings.approve),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
