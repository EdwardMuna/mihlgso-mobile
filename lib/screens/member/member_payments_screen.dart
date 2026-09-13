import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../models/payment.dart';
import '../../providers/member_providers.dart';
import '../../widgets/state_views.dart';

class MemberPaymentsScreen extends ConsumerWidget {
  const MemberPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final dateFmt = DateFormat.yMMMd();
    final strings = AppStrings.of(context);

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
              itemCount: payments.length,
              itemBuilder: (context, i) {
                final p = payments[i];
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
