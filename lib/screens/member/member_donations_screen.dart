import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../models/donation.dart';
import '../../models/payment.dart' show ApprovalStatus;
import '../../providers/member_providers.dart';
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
              itemCount: donations.length,
              itemBuilder: (context, i) {
                final d = donations[i];
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
