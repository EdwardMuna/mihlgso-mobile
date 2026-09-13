import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/payment.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/state_views.dart';
import 'admin_payment_add_screen.dart';
import 'admin_payment_edit_screen.dart';

const _pendingApprovalFilter = 'PENDING_APPROVAL';

class AdminPaymentsScreen extends ConsumerStatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  ConsumerState<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends ConsumerState<AdminPaymentsScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = 'ALL';
  DateTimeRange? _dateRange;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _approve(BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(adminServiceProvider).approvePayment(id);
      ref.invalidate(adminPaymentsProvider);
      ref.invalidate(adminOrgStatsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(adminServiceProvider).rejectPayment(id);
      ref.invalidate(adminPaymentsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, int id) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deletePaymentTitle),
        content: Text(strings.deletePaymentMessage),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminServiceProvider).deletePayment(id);
      ref.invalidate(adminPaymentsProvider);
      ref.invalidate(adminOrgStatsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _addPayment(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminPaymentAddScreen()));
  }

  Future<void> _editPayment(BuildContext context, WidgetRef ref, Payment payment) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminPaymentEditScreen(payment: payment)));
  }

  Color _statusColor(BuildContext context, ApprovalStatus status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return scheme.error;
      case ApprovalStatus.pending:
        return Colors.orange;
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  List<Payment> _applyFilters(List<Payment> payments) {
    final q = _searchController.text.trim().toLowerCase();
    return payments.where((p) {
      if (_statusFilter == _pendingApprovalFilter && p.approvalStatus != ApprovalStatus.pending) {
        return false;
      } else if (_statusFilter == 'PAID' && p.status != PaymentStatus.paid) {
        return false;
      } else if (_statusFilter == 'PARTIAL' && p.status != PaymentStatus.partial) {
        return false;
      } else if (_statusFilter == 'NOT_PAID' && p.status != PaymentStatus.notPaid) {
        return false;
      } else if (_statusFilter == 'APPROVED' && p.approvalStatus != ApprovalStatus.approved) {
        return false;
      } else if (_statusFilter == 'REJECTED' && p.approvalStatus != ApprovalStatus.rejected) {
        return false;
      }
      if (_dateRange != null) {
        final d = DateTime(p.paymentDate.year, p.paymentDate.month, p.paymentDate.day);
        final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
        if (d.isBefore(start) || d.isAfter(end)) return false;
      }
      if (q.isNotEmpty) {
        final haystack = [
          p.paymentName,
          p.reference ?? '',
          p.memberName ?? '',
          p.memberEmail ?? '',
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final paymentsAsync = ref.watch(adminPaymentsProvider);
    final dateFmt = DateFormat.yMMMd();
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addPayment(context, ref),
        tooltip: strings.addPaymentTooltip,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminPaymentsProvider),
      child: paymentsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminPaymentsProvider)),
        data: (allPayments) {
          // Running remaining balance must be computed from the FULL, unfiltered
          // list (mirrors the website's payments/page.tsx logic), then applied
          // to whichever rows are currently visible.
          final remainingById = computeRunningRemaining(allPayments);
          final payments = _applyFilters(allPayments);

          final totalDue = payments.fold<double>(0, (sum, p) => sum + p.amountDue);
          final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amountPaid);
          final totalRemaining = payments.fold<double>(0, (sum, p) => sum + (remainingById[p.id] ?? p.amountRemaining));

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildFilters(context),
              const SizedBox(height: AppSpacing.sm),
              if (payments.isNotEmpty)
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 4,
                      children: [
                        Text('${strings.totalDue}: ${currency.format(totalDue)}', style: Theme.of(context).textTheme.bodyMedium),
                        Text('${strings.totalPaid}: ${currency.format(totalPaid)}', style: Theme.of(context).textTheme.bodyMedium),
                        Text('${strings.totalRemainingPrefix}: ${currency.format(totalRemaining)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              if (payments.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: EmptyView(message: strings.noPaymentsMatchFilters, icon: Icons.payments_outlined),
                )
              else
                for (final p in payments)
                  Card(
                    child: InkWell(
                      onTap: () => _editPayment(context, ref, p),
                      child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(p.paymentName, style: Theme.of(context).textTheme.titleMedium),
                              ),
                              Chip(
                                label: Text(p.approvalStatus.name.toUpperCase()),
                                backgroundColor: _statusColor(context, p.approvalStatus).withValues(alpha: 0.15),
                                labelStyle: TextStyle(color: _statusColor(context, p.approvalStatus)),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                          if (p.memberName != null && p.memberName!.isNotEmpty)
                            Text(p.memberName!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                          if (p.contributionType != null) Text(p.contributionType!.name),
                          Text('${strings.duePrefix} ${currency.format(p.amountDue)} · ${strings.paidPrefix} ${currency.format(p.amountPaid)} · ${strings.remainingPrefix} ${currency.format(remainingById[p.id] ?? p.amountRemaining)}'),
                          Chip(
                            label: Text(p.status.name.toUpperCase()),
                            visualDensity: VisualDensity.compact,
                          ),
                          if (p.reference != null && p.reference!.isNotEmpty) Text('${strings.refPrefix}${p.reference}'),
                          if (p.notes != null && p.notes!.isNotEmpty) Text(p.notes!, style: Theme.of(context).textTheme.bodySmall),
                          Text('${strings.paymentDatePrefix} ${dateFmt.format(p.paymentDate)}', style: Theme.of(context).textTheme.bodySmall),
                          if (p.reviewedAt != null)
                            Text('${strings.reviewedPrefix} ${dateFmt.format(p.reviewedAt!)}', style: Theme.of(context).textTheme.bodySmall),
                          if (p.createdAt != null)
                            Text('${strings.recordedPrefix} ${dateFmt.format(p.createdAt!)}', style: Theme.of(context).textTheme.bodySmall),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              IconButton(
                                tooltip: strings.deleteTooltip,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _delete(context, ref, p.id),
                              ),
                              const Spacer(),
                              if (p.approvalStatus == ApprovalStatus.pending) ...[
                                OutlinedButton(
                                  onPressed: () => _reject(context, ref, p.id),
                                  child: Text(strings.reject),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                FilledButton(
                                  onPressed: () => _approve(context, ref, p.id),
                                  child: Text(strings.approve),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      ),
                    ),
                  ),
            ],
          );
        },
      ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    final strings = AppStrings.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: strings.searchPaymentsHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
            isDense: true,
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(_searchController.clear)),
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            DropdownButton<String>(
              value: _statusFilter,
              items: [
                DropdownMenuItem(value: 'ALL', child: Text(strings.allStatuses)),
                DropdownMenuItem(value: _pendingApprovalFilter, child: Text(strings.pendingApproval)),
                DropdownMenuItem(value: 'APPROVED', child: Text(strings.approvedStatus)),
                DropdownMenuItem(value: 'REJECTED', child: Text(strings.rejectedStatus)),
                DropdownMenuItem(value: 'PAID', child: Text(strings.paidStatus)),
                DropdownMenuItem(value: 'PARTIAL', child: Text(strings.partiallyPaidStatus)),
                DropdownMenuItem(value: 'NOT_PAID', child: Text(strings.notPaidStatus)),
              ],
              onChanged: (v) => setState(() => _statusFilter = v ?? 'ALL'),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickDateRange(context),
              icon: const Icon(Icons.date_range_outlined, size: 18),
              label: Text(_dateRange == null
                  ? strings.dateRange
                  : '${DateFormat.yMd().format(_dateRange!.start)} – ${DateFormat.yMd().format(_dateRange!.end)}'),
            ),
            if (_dateRange != null)
              IconButton(
                tooltip: strings.clearDateRange,
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _dateRange = null),
              ),
          ],
        ),
      ],
    );
  }
}
