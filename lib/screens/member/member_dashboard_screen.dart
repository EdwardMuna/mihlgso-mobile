import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_providers.dart';
import '../../models/contribution_type.dart';
import '../../models/payment.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tinted_stat_card.dart';
import 'member_shell.dart' show memberTabIndexProvider;
import 'record_payment_sheet.dart';

class MemberDashboardScreen extends ConsumerWidget {
  const MemberDashboardScreen({super.key});

  Future<void> _onDuesCardTap(
    BuildContext context,
    WidgetRef ref,
    ContributionType type,
    bool isPaid,
  ) async {
    if (isPaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).alreadyPaidInFull)),
      );
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RecordPaymentSheet(initialContributionTypeId: type.id),
    );
    if (saved == true) ref.invalidate(myPaymentsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    final paymentsAsync = ref.watch(myPaymentsProvider);
    final orgTotalsAsync = ref.watch(orgTotalsProvider);
    final typesAsync = ref.watch(contributionTypesProvider);
    final scheme = Theme.of(context).colorScheme;
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final strings = AppStrings.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myPaymentsProvider);
        ref.invalidate(orgTotalsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _WelcomeHeader(name: user?.name ?? '', email: user?.email ?? '', welcomeBack: strings.welcomeBack),
          const SizedBox(height: AppSpacing.lg),
          // Org-wide totals — same figures the admin dashboard shows, not
          // just this member's own payments/donations, for transparency.
          orgTotalsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: LoadingView(),
            ),
            error: (e, _) => ErrorRetryView(
              message: e.toString(),
              onRetry: () => ref.invalidate(orgTotalsProvider),
            ),
            data: (totals) => Row(
              children: [
                Expanded(
                  child: TintedStatCard(
                    label: strings.totalPaid,
                    value: currency.format(totals.totalPaid),
                    icon: Icons.payments,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TintedStatCard(
                    label: strings.totalDonated,
                    value: currency.format(totals.totalDonated),
                    icon: Icons.volunteer_activism,
                    color: AppColors.accentStrong,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
              return typesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: LoadingView(),
                ),
                error: (e, _) => ErrorRetryView(
                  message: e.toString(),
                  onRetry: () => ref.invalidate(contributionTypesProvider),
                ),
                data: (types) => _ContributionDuesGrid(
                  types: types,
                  payments: payments,
                  currency: currency,
                  scheme: scheme,
                  paidLabel: strings.paidStatus,
                  notPaidLabel: strings.notPaidStatus,
                  onCardTap: (type, isPaid) => _onDuesCardTap(context, ref, type, isPaid),
                ),
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

/// Matches a contribution type by keyword rather than exact name, so the
/// dashboard stays correct even if an admin tweaks the exact wording (e.g.
/// "Office construction levy" vs "Office Construction").
class _ContributionSpec {
  const _ContributionSpec({required this.keyword, required this.icon, required this.paidColor});
  final String keyword;
  final IconData icon;
  final Color paidColor;
}

const _contributionSpecs = [
  _ContributionSpec(keyword: 'annual', icon: Icons.card_membership_outlined, paidColor: AppColors.primary),
  _ContributionSpec(keyword: 'construction', icon: Icons.apartment_outlined, paidColor: AppColors.secondary),
  _ContributionSpec(keyword: 'yatima', icon: Icons.favorite_outline, paidColor: AppColors.accentStrong),
];

/// Replaces the old flat "total due"/"total paid" cards with one tile per
/// tracked contribution (Annual Subscription, Office Construction, Yatima
/// Project): red-tinted (same design as the old "total due" card) while the
/// member still owes on it, or the normal admin-dashboard tinted style once
/// fully paid.
class _ContributionDuesGrid extends StatelessWidget {
  const _ContributionDuesGrid({
    required this.types,
    required this.payments,
    required this.currency,
    required this.scheme,
    required this.paidLabel,
    required this.notPaidLabel,
    required this.onCardTap,
  });

  final List<ContributionType> types;
  final List<Payment> payments;
  final NumberFormat currency;
  final ColorScheme scheme;
  final String paidLabel;
  final String notPaidLabel;
  final void Function(ContributionType type, bool isPaid) onCardTap;

  ContributionType? _matchType(String keyword) {
    for (final t in types) {
      if (t.name.toLowerCase().contains(keyword)) return t;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];
    for (final spec in _contributionSpecs) {
      final type = _matchType(spec.keyword);
      if (type == null) continue;
      final paidForType = payments
          .where((p) => p.contributionTypeId == type.id && p.approvalStatus == ApprovalStatus.approved)
          .fold<double>(0, (sum, p) => sum + p.amountPaid);
      final remaining = (type.amount - paidForType).clamp(0, double.infinity);
      final isPaid = remaining <= 0;
      final statusColor = isPaid ? spec.paidColor : scheme.error;
      cards.add(
        TintedStatCard(
          label: type.name,
          value: currency.format(isPaid ? type.amount : remaining),
          icon: isPaid ? Icons.check_circle_outline : spec.icon,
          color: statusColor,
          onTap: () => onCardTap(type, isPaid),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              isPaid ? paidLabel : notPaidLabel,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    if (cards.isEmpty) return const SizedBox.shrink();

    // Two per row, but a trailing odd card out (Yatima Project, once Annual
    // Subscription and Office Construction fill the first row) is centered
    // at half width instead of stretching across the row on its own.
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
