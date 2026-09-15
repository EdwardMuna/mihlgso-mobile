import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_providers.dart';
import '../../models/payment.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tinted_stat_card.dart';
import 'member_shell.dart' show memberTabIndexProvider;

/// Mirrors the website's member dashboard (app/[locale]/member/page.tsx):
/// three stat cards for the member's own totals — Total Contributed, the
/// combined Overall Total, and Total Donated — followed by their recent
/// payments.
class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final donationsAsync = ref.watch(myDonationsProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final strings = AppStrings.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myPaymentsProvider);
        ref.invalidate(myDonationsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _WelcomeHeader(name: user?.name ?? '', email: user?.email ?? '', welcomeBack: strings.welcomeBack),
          const SizedBox(height: AppSpacing.lg),
          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: LoadingView(),
            ),
            error: (e, _) => ErrorRetryView(
              message: e.toString(),
              onRetry: () => ref.invalidate(myPaymentsProvider),
            ),
            data: (payments) {
              // Only approved contributions count toward the member's
              // totals, same as the website's aggregation.
              final totalContributed = payments
                  .where((p) => p.approvalStatus == ApprovalStatus.approved)
                  .fold<double>(0, (sum, p) => sum + p.amountPaid);
              return donationsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: LoadingView(),
                ),
                error: (e, _) => ErrorRetryView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(myDonationsProvider),
                ),
                data: (donations) {
                  final totalDonated = donations
                      .where((d) => d.approvalStatus == ApprovalStatus.approved)
                      .fold<double>(0, (sum, d) => sum + d.amount);
                  return _StatCardsRow(
                    totalContributed: totalContributed,
                    totalDonated: totalDonated,
                    currency: currency,
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.recentPayments, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              paymentsAsync.maybeWhen(
                data: (payments) => payments.isEmpty
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () => ref.read(memberTabIndexProvider.notifier).state = 1,
                        child: Text(strings.viewAll),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          paymentsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (payments) {
              if (payments.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: EmptyView(message: strings.noPaymentsRecordedYet, icon: Icons.payments_outlined),
                );
              }
              final recent = [...payments]..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
              return Column(
                children: recent.take(3).map((p) => _PaymentTile(payment: p, currency: currency)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatCardsRow extends StatelessWidget {
  const _StatCardsRow({
    required this.totalContributed,
    required this.totalDonated,
    required this.currency,
  });

  final double totalContributed;
  final double totalDonated;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Row(
      children: [
        Expanded(
          child: TintedStatCard(
            label: strings.totalContributed,
            value: currency.format(totalContributed),
            icon: Icons.payments_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TintedStatCard(
            label: strings.totalContributedAndDonated,
            value: currency.format(totalContributed + totalDonated),
            icon: Icons.stacked_line_chart_outlined,
            color: AppColors.secondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TintedStatCard(
            label: strings.totalDonated,
            value: currency.format(totalDonated),
            icon: Icons.volunteer_activism_outlined,
            color: AppColors.accentStrong,
          ),
        ),
      ],
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.name, required this.email, required this.welcomeBack});
  final String name;
  final String email;
  final String welcomeBack;

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  welcomeBack,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                ),
                Text(
                  name,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment, required this.currency});
  final Payment payment;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final color = switch (payment.status) {
      PaymentStatus.paid => AppColors.secondary,
      PaymentStatus.partial => AppColors.accentStrong,
      PaymentStatus.notPaid => Theme.of(context).colorScheme.error,
    };
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(Icons.receipt_long, color: color),
        ),
        title: Text(payment.paymentName, overflow: TextOverflow.ellipsis),
        subtitle: Text('${currency.format(payment.amountPaid)} of ${currency.format(payment.amountDue)}'),
        trailing: Text(
          payment.status.name,
          style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
    );
  }
}
