import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/donation.dart';
import '../../models/payment.dart' show ApprovalStatus;
import '../../providers/member_providers.dart';
import '../../services/export_service.dart';
import '../../widgets/export_buttons.dart';
import '../../widgets/state_views.dart';
import 'record_donation_sheet.dart';

class MemberDonationsScreen extends ConsumerWidget {
  const MemberDonationsScreen({super.key});

  Future<void> _editDonation(BuildContext context, WidgetRef ref, Donation donation) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecordDonationSheet(existing: donation),
    );
    if (saved == true) ref.invalidate(myDonationsProvider);
  }

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

  String _approvalStatusLabel(AppStrings strings, ApprovalStatus status) => switch (status) {
        ApprovalStatus.approved => strings.approvedStatus,
        ApprovalStatus.rejected => strings.rejectedStatus,
        ApprovalStatus.pending => strings.pendingApproval,
      };

  // Mirrors the website's exportColumns/exportRows/exportTotalRow in
  // app/[locale]/member/donate/page.tsx: "#", Purpose, Reference, Amount,
  // Approval, Date — no Donor column (this is the member's own list) —
  // the totals row's label sits under Purpose, its value under Amount.
  ExportData _buildExportData(AppStrings strings, List<Donation> donations, NumberFormat currency, DateFormat dateFmt) {
    final totalAmount = donations.fold<double>(0, (sum, d) => sum + d.amount);
    final rows = <List<String>>[];
    for (var i = 0; i < donations.length; i++) {
      final d = donations[i];
      rows.add([
        '${i + 1}',
        d.purpose ?? strings.generalPurpose,
        d.reference ?? '',
        currency.format(d.amount),
        _approvalStatusLabel(strings, d.approvalStatus),
        dateFmt.format(d.donatedAt),
      ]);
    }
    return ExportData(
      headers: ['#', strings.purposeLabel, strings.referenceLabel, strings.amount, strings.approval, strings.date],
      rows: rows,
      totalRow: donations.isEmpty
          ? null
          : [
              strings.totalAmountDonated,
              '',
              '',
              currency.format(totalAmount),
              '',
              '',
            ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationsAsync = ref.watch(myDonationsProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final dateFmt = DateFormat.yMMMd();
    final strings = AppStrings.of(context);

    return RefreshIndicator(
        onRefresh: () async => ref.invalidate(myDonationsProvider),
        child: donationsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(myDonationsProvider)),
          data: (donations) {
            if (donations.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noDonationsYetTapRecord, icon: Icons.volunteer_activism_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
              itemCount: donations.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ExportButtonsRow(
                        onExcel: () => _export(context, () => ExportService.exportExcel(
                              filename: 'my_donations',
                              title: strings.exportedFileTitleMyDonations,
                              data: _buildExportData(strings, donations, currency, dateFmt),
                            )),
                        onPdf: () => _export(context, () => ExportService.exportPdf(
                              filename: 'my_donations',
                              title: strings.exportedFileTitleMyDonations,
                              data: _buildExportData(strings, donations, currency, dateFmt),
                            )),
                      ),
                    ),
                  );
                }
                final d = donations[index - 1];
                final color = switch (d.approvalStatus) {
                  ApprovalStatus.approved => Colors.green,
                  ApprovalStatus.pending => Colors.orange,
                  ApprovalStatus.rejected => Colors.red,
                };
                final isPending = d.approvalStatus == ApprovalStatus.pending;
                return Card(
                  child: ListTile(
                    title: Text(currency.format(d.amount)),
                    subtitle: Text('${d.purpose ?? strings.generalPurpose}\n${dateFmt.format(d.donatedAt)}'),
                    isThreeLine: true,
                    onTap: isPending ? () => _editDonation(context, ref, d) : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Chip(
                          label: Text(d.approvalStatus.name, style: TextStyle(color: color)),
                          backgroundColor: color.withValues(alpha: 0.12),
                          side: BorderSide.none,
                        ),
                        if (isPending) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.edit_outlined, size: 18),
                        ],
                      ],
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
