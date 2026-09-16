import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/member_providers.dart';
import '../../widgets/leaderboard_card.dart';
import '../../widgets/state_views.dart';

/// Mirrors the website's app/[locale]/member/donors "All Donors" page — the
/// full (non-truncated) list behind the dashboard's "View all".
class MemberDonorsScreen extends ConsumerWidget {
  const MemberDonorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final resultAsync = ref.watch(allDonorsProvider(strings.generalProject));
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: Text(strings.topDonorsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(allDonorsProvider(strings.generalProject)),
        child: resultAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(
            message: e.toString(),
            onRetry: () => ref.invalidate(allDonorsProvider(strings.generalProject)),
          ),
          data: (result) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              LeaderboardCard(
                title: strings.topDonorsTitle,
                icon: Icons.volunteer_activism_outlined,
                accent: AppColors.accentStrong,
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
