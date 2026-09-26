import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/payment.dart';
import '../../providers/member_providers.dart';
import '../../services/export_service.dart';
import '../../widgets/export_buttons.dart';
import '../../widgets/state_views.dart';
import '../../widgets/where_to_pay_sheet.dart';

class MemberPaymentsScreen extends ConsumerWidget {
  const MemberPaymentsScreen({super.key});

  Future<void> _export(BuildContext context, Future<void> Function() run) async {
    try {
      await run();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).savedToDownloads)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _paymentStatusLabel(AppStrings strings, PaymentStatus status) => switch (status) {
        PaymentStatus.paid => strings.paidStatus,
        PaymentStatus.partial => strings.partiallyPaidStatus,
        PaymentStatus.notPaid => strings.notPaidStatus,
      };

  String _approvalStatusLabel(AppStrings strings, ApprovalStatus status) => switch (status) {
        ApprovalStatus.approved => strings.approvedStatus,
        ApprovalStatus.rejected => strings.rejectedStatus,
        ApprovalStatus.pending => strings.pendingApproval,
      };

  // Mirrors the website's exportColumns/exportRows/exportTotalRow in
  // app/[locale]/member/payments/page.tsx: "#", Payment, Reference, Due,
  // Paid, Remaining, Status, Approval, Date — no Member column (this is
  // the member's own list) — the totals row's label sits under Payment,
  // its value under Paid.
  ExportData _buildExportData(
    AppStrings strings,
    List<Payment> payments,
    NumberFormat currency,
    DateFormat dateFmt,
  ) {
    final remainingById = computeRunningRemaining(payments);
    final totalPaid = payments.fold<double>(0, (sum, p) => sum + p.amountPaid);
    final rows = <List<String>>[];
    for (var i = 0; i < payments.length; i++) {
      final p = payments[i];
      rows.add([
        '${i + 1}',
        p.paymentName,
        p.reference ?? '',
        currency.format(p.amountDue),
        currency.format(p.amountPaid),
        currency.format(remainingById[p.id] ?? p.amountRemaining),
        _paymentStatusLabel(strings, p.status),
        _approvalStatusLabel(strings, p.approvalStatus),
        dateFmt.format(p.paymentDate),
      ]);
    }
    return ExportData(
      headers: ['#', strings.payment, strings.referenceLabel, strings.duePrefix, strings.paidPrefix, strings.remainingPrefix, strings.status, strings.approval, strings.date],
      rows: rows,
      totalRow: payments.isEmpty
          ? null
          : [
              strings.totalAmountPaid,
              '',
              '',
              '',
              currency.format(totalPaid),
              '',
              '',
              '',
              '',
            ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final contributionTypesAsync = ref.watch(contributionTypesProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final dateFmt = DateFormat.yMMMd();
    final strings = AppStrings.of(context);
    final bankAccounts = contributionTypesAsync.asData?.value.where((c) => c.hasBankAccount).toList() ?? const [];

    return RefreshIndicator(
        onRefresh: () async => ref.invalidate(myPaymentsProvider),
        child: paymentsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(myPaymentsProvider)),
          data: (payments) {
            if (payments.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noPaymentsYetTapRecord, icon: Icons.payments_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: payments.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: AppSpacing.sm,
                      children: [
                        WhereToPayButton(
                          accounts: bankAccounts,
                          currency: (v) => currency.format(v),
                        ),
                        ExportButtonsRow(
                          onExcel: () => _export(context, () => ExportService.exportExcel(
                                filename: 'my_contributions',
                                title: strings.exportedFileTitleMyPayments,
                                data: _buildExportData(strings, payments, currency, dateFmt),
                              )),
                          onPdf: () => _export(context, () => ExportService.exportPdf(
                                filename: 'my_contributions',
                                title: strings.exportedFileTitleMyPayments,
                                data: _buildExportData(strings, payments, currency, dateFmt),
                              )),
                        ),
                      ],
                    ),
                  );
                }
                final p = payments[index - 1];
                final color = switch (p.approvalStatus) {
                  ApprovalStatus.approved => Colors.green,
                  ApprovalStatus.pending => Colors.orange,
                  ApprovalStatus.rejected => Colors.red,
                };
                return Card(
                  child: ListTile(
                    title: Text(p.paymentName),
                    subtitle: Text(
                      '${p.contributionType?.name ?? ''}\n'
                      '${dateFmt.format(p.paymentDate)} · ${currency.format(p.amountPaid)} of ${currency.format(p.amountDue)}'
                      '${p.reviewedAt != null ? ' · Reviewed ${dateFmt.format(p.reviewedAt!)}' : ''}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(p.approvalStatus.name, style: TextStyle(color: color)),
                      backgroundColor: color.withValues(alpha: 0.12),
                      side: BorderSide.none,
                    ),
                  ),
                );
              },
            );
          },
        ),
    );
  }
}
