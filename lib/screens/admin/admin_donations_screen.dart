import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../models/donation.dart';
import '../../models/payment.dart' show ApprovalStatus;
import '../../providers/admin_providers.dart';
import '../../widgets/state_views.dart';

class AdminDonationsScreen extends ConsumerStatefulWidget {
  const AdminDonationsScreen({super.key});

  @override
  ConsumerState<AdminDonationsScreen> createState() => _AdminDonationsScreenState();
}

class _AdminDonationsScreenState extends ConsumerState<AdminDonationsScreen> {
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
      await ref.read(adminServiceProvider).approveDonation(id);
      ref.invalidate(adminDonationsProvider);
      ref.invalidate(adminOrgStatsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref, int id) async {
    try {
      await ref.read(adminServiceProvider).rejectDonation(id);
      ref.invalidate(adminDonationsProvider);
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
        title: Text(strings.deleteDonationTitle),
        content: Text(strings.deleteDonationMessage),
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
      await ref.read(adminServiceProvider).deleteDonation(id);
      ref.invalidate(adminDonationsProvider);
      ref.invalidate(adminOrgStatsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
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

  List<Donation> _applyFilters(List<Donation> donations) {
    final q = _searchController.text.trim().toLowerCase();
    return donations.where((d) {
      if (_statusFilter == 'PENDING' && d.approvalStatus != ApprovalStatus.pending) return false;
      if (_statusFilter == 'APPROVED' && d.approvalStatus != ApprovalStatus.approved) return false;
      if (_statusFilter == 'REJECTED' && d.approvalStatus != ApprovalStatus.rejected) return false;
      if (_dateRange != null) {
        final d0 = DateTime(d.donatedAt.year, d.donatedAt.month, d.donatedAt.day);
        final start = DateTime(_dateRange!.start.year, _dateRange!.start.month, _dateRange!.start.day);
        final end = DateTime(_dateRange!.end.year, _dateRange!.end.month, _dateRange!.end.day);
        if (d0.isBefore(start) || d0.isAfter(end)) return false;
      }
      if (q.isNotEmpty) {
        final haystack = [
          d.donorName,
          d.donorEmail ?? '',
          d.donorPhone ?? '',
          d.purpose ?? '',
          d.reference ?? '',
          d.memberName ?? '',
          d.memberEmail ?? '',
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _showAddDonationDialog(BuildContext context, WidgetRef ref) async {
    final strings = AppStrings.of(context);
    final formKey = GlobalKey<FormState>();
    final donorNameController = TextEditingController();
    final donorEmailController = TextEditingController();
    final donorPhoneController = TextEditingController();
    final amountController = TextEditingController();
    final purposeController = TextEditingController();
    final referenceController = TextEditingController();
    final notesController = TextEditingController();
    DateTime donatedAt = DateTime.now();
    var submitting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            return AlertDialog(
              title: Text(strings.recordDonation),
              content: SizedBox(
                width: 420,
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: donorNameController,
                          decoration: InputDecoration(labelText: strings.donorNameRequired),
                          validator: (v) => (v == null || v.trim().isEmpty) ? strings.required : null,
                        ),
                        TextFormField(
                          controller: donorEmailController,
                          decoration: InputDecoration(labelText: strings.donorEmail),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        TextFormField(
                          controller: donorPhoneController,
                          decoration: InputDecoration(labelText: strings.donorPhone),
                          keyboardType: TextInputType.phone,
                        ),
                        TextFormField(
                          controller: amountController,
                          decoration: InputDecoration(labelText: strings.amountRequired),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) {
                            final n = double.tryParse(v ?? '');
                            if (n == null || n <= 0) return strings.enterValidAmount;
                            return null;
                          },
                        ),
                        Row(
                          children: [
                            Expanded(child: Text('${strings.dateLabel}: ${DateFormat.yMMMd().format(donatedAt)}')),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: donatedAt,
                                  firstDate: DateTime(DateTime.now().year - 10),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                );
                                if (picked != null) setLocalState(() => donatedAt = picked);
                              },
                              child: Text(strings.changeButton),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: purposeController,
                          decoration: InputDecoration(labelText: strings.purposeLabel),
                        ),
                        TextFormField(
                          controller: referenceController,
                          decoration: InputDecoration(labelText: strings.referenceLabel),
                        ),
                        TextFormField(
                          controller: notesController,
                          decoration: InputDecoration(labelText: strings.notesLabel),
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(dialogContext),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) return;
                          setLocalState(() => submitting = true);
                          try {
                            await ref.read(adminServiceProvider).createDonation(
                                  donorName: donorNameController.text.trim(),
                                  amount: double.parse(amountController.text.trim()),
                                  donatedAt: donatedAt,
                                  donorEmail: donorEmailController.text.trim().isEmpty ? null : donorEmailController.text.trim(),
                                  donorPhone: donorPhoneController.text.trim().isEmpty ? null : donorPhoneController.text.trim(),
                                  purpose: purposeController.text.trim().isEmpty ? null : purposeController.text.trim(),
                                  reference: referenceController.text.trim().isEmpty ? null : referenceController.text.trim(),
                                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                                );
                            ref.invalidate(adminDonationsProvider);
                            if (dialogContext.mounted) Navigator.pop(dialogContext);
                          } on ApiException catch (e) {
                            setLocalState(() => submitting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.message)));
                            }
                          }
                        },
                  child: submitting
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(strings.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final donationsAsync = ref.watch(adminDonationsProvider);
    final dateFmt = DateFormat.yMMMd();
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDonationDialog(context, ref),
        tooltip: strings.recordDonationTooltip,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminDonationsProvider),
        child: donationsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminDonationsProvider)),
          data: (allDonations) {
            final donations = _applyFilters(allDonations);
            final totalAmount = donations.fold<double>(0, (sum, d) => sum + d.amount);

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildFilters(context),
                const SizedBox(height: AppSpacing.sm),
                if (donations.isNotEmpty)
                  Card(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text('${strings.totalDonatedPrefix} ${currency.format(totalAmount)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                if (donations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: EmptyView(message: strings.noDonationsMatchFilters, icon: Icons.volunteer_activism_outlined),
                  )
                else
                  for (final d in donations)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(d.donorName, style: Theme.of(context).textTheme.titleMedium),
                                ),
                                Chip(
                                  label: Text(d.approvalStatus.name.toUpperCase()),
                                  backgroundColor: _statusColor(context, d.approvalStatus).withValues(alpha: 0.15),
                                  labelStyle: TextStyle(color: _statusColor(context, d.approvalStatus)),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                            if (d.memberEmail != null && d.memberEmail!.isNotEmpty)
                              Text('${strings.memberPrefix}${d.memberName ?? d.memberEmail}', style: Theme.of(context).textTheme.bodySmall)
                            else if ((d.donorEmail != null && d.donorEmail!.isNotEmpty) || (d.donorPhone != null && d.donorPhone!.isNotEmpty))
                              Text(
                                [d.donorEmail, d.donorPhone].where((v) => v != null && v.isNotEmpty).join(' · '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            Text(currency.format(d.amount)),
                            if (d.purpose != null && d.purpose!.isNotEmpty) Text(d.purpose!),
                            if (d.reference != null && d.reference!.isNotEmpty) Text('${strings.refPrefix}${d.reference}'),
                            if (d.notes != null && d.notes!.isNotEmpty) Text(d.notes!, style: Theme.of(context).textTheme.bodySmall),
                            Text('${strings.donatedPrefix} ${dateFmt.format(d.donatedAt)}', style: Theme.of(context).textTheme.bodySmall),
                            if (d.reviewedAt != null)
                              Text('${strings.reviewedPrefix} ${dateFmt.format(d.reviewedAt!)}', style: Theme.of(context).textTheme.bodySmall),
                            if (d.createdAt != null)
                              Text('${strings.recordedPrefix} ${dateFmt.format(d.createdAt!)}', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: strings.deleteTooltip,
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _delete(context, ref, d.id),
                                ),
                                const Spacer(),
                                if (d.approvalStatus == ApprovalStatus.pending) ...[
                                  OutlinedButton(
                                    onPressed: () => _reject(context, ref, d.id),
                                    child: Text(strings.reject),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  FilledButton(
                                    onPressed: () => _approve(context, ref, d.id),
                                    child: Text(strings.approve),
                                  ),
                                ],
                              ],
                            ),
                          ],
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
            hintText: strings.searchDonationsHint,
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
                DropdownMenuItem(value: 'PENDING', child: Text(strings.pendingApproval)),
                DropdownMenuItem(value: 'APPROVED', child: Text(strings.approvedStatus)),
                DropdownMenuItem(value: 'REJECTED', child: Text(strings.rejectedStatus)),
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
