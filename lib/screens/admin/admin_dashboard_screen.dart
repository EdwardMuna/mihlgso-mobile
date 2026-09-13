import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_providers.dart';
import '../../providers/mosms_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/tinted_stat_card.dart';
import 'admin_shell.dart' show adminTabIndexProvider;

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _editBeneficiaries(BuildContext context, WidgetRef ref, int current) async {
    final controller = TextEditingController(text: '$current');
    final strings = AppStrings.of(context);
    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.beneficiariesServedTitle),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: strings.totalBeneficiaries),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(strings.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())),
            child: Text(strings.save),
          ),
        ],
      ),
    );
    if (result == null) return;
    try {
      await ref.read(adminServiceProvider).updateOrgStats(result);
      ref.invalidate(adminOrgStatsProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminOrgStatsProvider);
    final mosmsBalanceAsync = ref.watch(mosmsBalanceProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);
    final strings = AppStrings.of(context);

    return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminOrgStatsProvider);
          ref.invalidate(mosmsBalanceProvider);
        },
        child: statsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminOrgStatsProvider)),
          data: (stats) {
            final smsCard = mosmsBalanceAsync.when(
              loading: () => TintedStatCard(
                label: strings.smsBalance,
                value: '…',
                icon: Icons.sms_outlined,
                color: AppColors.secondary,
              ),
              error: (e, _) => TintedStatCard(
                label: strings.smsBalance,
                value: '—',
                icon: Icons.sms_outlined,
                color: AppColors.secondary,
              ),
              data: (balance) => TintedStatCard(
                label: strings.smsBalance,
                value: '${balance.smsBalance}',
                icon: Icons.sms_outlined,
                color: AppColors.secondary,
              ),
            );
            final whatsappCard = mosmsBalanceAsync.when(
              loading: () => TintedStatCard(
                label: strings.whatsappBalance,
                value: '…',
                icon: Icons.chat_outlined,
                color: AppColors.primary,
              ),
              error: (e, _) => TintedStatCard(
                label: strings.whatsappBalance,
                value: '—',
                icon: Icons.chat_outlined,
                color: AppColors.primary,
              ),
              data: (balance) => TintedStatCard(
                label: strings.whatsappBalance,
                value: '${balance.whatsappBalance}',
                icon: Icons.chat_outlined,
                color: AppColors.primary,
              ),
            );

            final cards = [
              smsCard,
              whatsappCard,
              TintedStatCard(
                label: strings.members,
                value: '${stats.memberCount}',
                icon: Icons.people,
                color: AppColors.primary,
                onTap: () => ref.read(adminTabIndexProvider.notifier).state = 2,
              ),
              TintedStatCard(
                label: strings.donors,
                value: '${stats.donorCount}',
                icon: Icons.favorite_outline,
                color: AppColors.accentStrong,
              ),
              TintedStatCard(
                label: strings.pendingApplications,
                value: '${stats.pendingApplications}',
                icon: Icons.pending_actions,
                color: AppColors.secondary,
                onTap: () => ref.read(adminTabIndexProvider.notifier).state = 1,
              ),
              TintedStatCard(
                label: strings.pendingApprovals,
                value: '${stats.pendingApprovals}',
                icon: Icons.rule_folder_outlined,
                color: AppColors.primaryDark,
                // Combines pending payments + donations server-side; Payments
                // is the primary approval workflow screen.
                onTap: () => ref.read(adminTabIndexProvider.notifier).state = 4,
              ),
              TintedStatCard(label: strings.contributionTypes, value: '${stats.contributionTypesCount}', icon: Icons.category_outlined, color: AppColors.secondaryDark),
              TintedStatCard(label: strings.totalPaid, value: currency.format(stats.totalPaid), icon: Icons.payments, color: AppColors.secondary),
              TintedStatCard(label: strings.totalDonated, value: currency.format(stats.totalDonated), icon: Icons.volunteer_activism, color: AppColors.accentStrong),
              TintedStatCard(
                label: strings.beneficiariesServedTitle,
                value: '${stats.beneficiariesCount}',
                icon: Icons.groups_outlined,
                color: AppColors.primary,
                onTap: () => _editBeneficiaries(context, ref, stats.beneficiariesCount),
                trailing: Icon(Icons.edit_outlined, size: 16, color: AppColors.primary.withValues(alpha: 0.6)),
              ),
            ];

            return LayoutBuilder(
              builder: (context, constraints) {
                // Size the grid to the available viewport instead of a fixed
                // aspect ratio, so it fills the device's actual width/height
                // (more columns on wider screens, cards sized to fit without
                // wasted space or overflow) rather than a one-size layout.
                final width = constraints.maxWidth;
                final crossAxisCount = width >= 900 ? 4 : (width >= 600 ? 3 : 2);
                const spacing = 12.0;
                final cardWidth = (width - AppSpacing.md * 2 - spacing * (crossAxisCount - 1)) / crossAxisCount;
                final rows = (cards.length / crossAxisCount).ceil();
                final availableHeight = constraints.maxHeight - AppSpacing.md * 2 - spacing * (rows - 1);
                final cardHeight = (availableHeight / rows).clamp(96.0, 160.0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: cardWidth / cardHeight,
                    children: cards,
                  ),
                );
              },
            );
          },
        ),
    );
  }
}
