import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_providers.dart';
import '../../models/annual_subscription.dart';
import '../../models/payment.dart';
import '../../widgets/leaderboard_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tinted_stat_card.dart';
import 'member_contributors_screen.dart';
import 'member_donors_screen.dart';
import 'member_shell.dart' show memberTabIndexProvider;

/// Mirrors the website's member dashboard (app/[locale]/member/page.tsx):
/// an Annual Subscription due card (when that contribution type exists),
/// the member's own totals (Total Contributed, Overall Total, Total
/// Donated), recent payments, and the Top Contributors/Top Donors
/// leaderboards.
class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final donationsAsync = ref.watch(myDonationsProvider);
    final annualSubscriptionAsync = ref.watch(annualSubscriptionProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final strings = AppStrings.of(context);
    final topContributorsAsync = ref.watch(topContributorsProvider);
    final topDonorsAsync = ref.watch(topDonorsProvider(strings.generalProject));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myPaymentsProvider);
        ref.invalidate(myDonationsProvider);
        ref.invalidate(annualSubscriptionProvider);
        ref.invalidate(topContributorsProvider);
        ref.invalidate(topDonorsProvider(strings.generalProject));
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
                  return _StatCardsGrid(
                    annualSubscription: annualSubscriptionAsync.valueOrNull,
                    totalContributed: totalContributed,
                    totalDonated: totalDonated,
                    currency: currency,
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          paymentsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: LoadingView(),
            ),
            error: (e, _) => const SizedBox.shrink(),
            data: (payments) {
              final recent = [...payments]..sort((a, b) => b.paymentDate.compareTo(a.paymentDate));
              return _SectionCard(
                title: strings.recentPayments,
                icon: Icons.history,
                accent: AppColors.primary,
                viewAllLabel: payments.isEmpty ? null : strings.viewAll,
                onViewAll: payments.isEmpty ? null : () => ref.read(memberTabIndexProvider.notifier).state = 1,
                child: payments.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: EmptyView(message: strings.noPaymentsRecordedYet, icon: Icons.payments_outlined),
                      )
                    : Column(
                        children: [
                          for (var i = 0; i < recent.take(3).length; i++) ...[
                            _PaymentTile(payment: recent[i], currency: currency),
                            if (i != recent.take(3).length - 1)
                              const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
                          ],
                        ],
                      ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          topContributorsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: LoadingView(),
            ),
            error: (e, _) => ErrorRetryView(
              message: e.toString(),
              onRetry: () => ref.invalidate(topContributorsProvider),
            ),
            data: (result) => LeaderboardCard(
              title: strings.topContributorsTitle,
              icon: Icons.emoji_events_outlined,
              accent: AppColors.primary,
              rows: result.rows,
              overallTotal: result.total,
              overallTotalLabel: strings.overallTotalLabel,
              emptyLabel: strings.leaderboardEmpty,
              currency: currency,
              viewAllLabel: strings.viewAll,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemberContributorsScreen()),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          topDonorsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: LoadingView(),
            ),
            error: (e, _) => ErrorRetryView(
              message: e.toString(),
              onRetry: () => ref.invalidate(topDonorsProvider(strings.generalProject)),
            ),
            data: (result) => LeaderboardCard(
              title: strings.topDonorsTitle,
              icon: Icons.volunteer_activism_outlined,
              accent: AppColors.accentStrong,
              rows: result.rows,
              overallTotal: result.total,
              overallTotalLabel: strings.overallTotalLabel,
              emptyLabel: strings.leaderboardEmpty,
              currency: currency,
              viewAllLabel: strings.viewAll,
              onViewAll: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemberDonorsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCardsGrid extends StatelessWidget {
  const _StatCardsGrid({
    required this.annualSubscription,
    required this.totalContributed,
    required this.totalDonated,
    required this.currency,
  });

  final AnnualSubscription? annualSubscription;
  final double totalContributed;
  final double totalDonated;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;

    final cards = <Widget>[];
    final sub = annualSubscription;
    if (sub != null) {
      final statusColor = sub.isPaid ? AppColors.secondary : scheme.error;
      cards.add(
        TintedStatCard(
          label: strings.annualSubscriptionBadge(sub.year),
          value: currency.format(sub.amount),
          icon: Icons.badge_outlined,
          color: statusColor,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              sub.isPaid ? strings.paidStatus : strings.notPaidStatus,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    cards.addAll([
      TintedStatCard(
        label: strings.totalContributed,
        value: currency.format(totalContributed),
        icon: Icons.payments_outlined,
        color: AppColors.primary,
      ),
      TintedStatCard(
        label: strings.totalContributedAndDonated,
        value: currency.format(totalContributed + totalDonated),
        icon: Icons.stacked_line_chart_outlined,
        color: AppColors.secondary,
      ),
      TintedStatCard(
        label: strings.myTotalDonated,
        value: currency.format(totalDonated),
        icon: Icons.volunteer_activism_outlined,
        color: AppColors.accentStrong,
      ),
    ]);

    // Two per row; a trailing odd card out (only when there's no Annual
    // Subscription card, leaving 3) is centered at half width instead of
    // stretching across the row on its own.
    const cardHeight = 108.0;
    const spacing = AppSpacing.sm;
    final rows = <Widget>[];
    for (var i = 0; i < cards.length; i += 2) {
      if (i + 1 < cards.length) {
        rows.add(SizedBox(
          height: cardHeight,
          child: Row(
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: spacing),
              Expanded(child: cards[i + 1]),
            ],
          ),
        ));
      } else {
        rows.add(SizedBox(
          height: cardHeight,
          child: Center(
            child: FractionallySizedBox(widthFactor: 0.5, child: cards[i]),
          ),
        ));
      }
      if (i + 2 < cards.length) rows.add(const SizedBox(height: spacing));
    }
    return Column(children: rows);
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
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6)),
        ],
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
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = switch (payment.status) {
      PaymentStatus.paid => AppColors.secondary,
      PaymentStatus.partial => AppColors.accentStrong,
      PaymentStatus.notPaid => scheme.error,
    };
    final label = switch (payment.status) {
      PaymentStatus.paid => strings.paidStatus,
      PaymentStatus.partial => strings.partiallyPaidStatus,
      PaymentStatus.notPaid => strings.notPaidStatus,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(Icons.receipt_long, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${currency.format(payment.amountPaid)} of ${currency.format(payment.amountDue)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bordered, shadowed container with an icon+title (+ optional "view all")
/// header — the shared shell behind "Recent contributions" and the
/// leaderboard cards, so every dashboard section reads as one visual family.
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.accent,
    required this.child,
    this.viewAllLabel,
    this.onViewAll,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final Widget child;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (viewAllLabel != null && onViewAll != null)
                  TextButton(onPressed: onViewAll, child: Text(viewAllLabel!)),
              ],
            ),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}
