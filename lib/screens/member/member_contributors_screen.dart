import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/member_providers.dart';
import '../../widgets/leaderboard_card.dart';
import '../../widgets/state_views.dart';

/// Mirrors the website's app/[locale]/member/contributors "All Contributors"
/// page — the full (non-truncated) list behind the dashboard's "View all".
class MemberContributorsScreen extends ConsumerWidget {
  const MemberContributorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultAsync = ref.watch(allContributorsProvider);
    final strings = AppStrings.of(context);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(strings.topContributorsAppBarTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allContributorsProvider),
        child: resultAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(allContributorsProvider)),
          data: (result) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LeaderboardCard(
                title: strings.topContributorsTitle,
                icon: Icons.emoji_events_outlined,
                accent: AppColors.primary,
                rows: result.rows,
                overallTotal: result.total,
                overallTotalLabel: strings.overallTotalLabel,
                emptyLabel: strings.leaderboardEmpty,
                currency: currency,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
