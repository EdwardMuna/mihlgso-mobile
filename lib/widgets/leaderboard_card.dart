import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme/app_theme.dart';
import '../models/leaderboard.dart';
import 'state_views.dart';

/// Mirrors the website's LeaderboardCard/LeaderboardTable (Top Contributors
/// / Top Donors sections on the member dashboard and their "view all" pages)
/// as a ranked list — easier to scan on a phone than the website's wide
/// data table, which needs horizontal scrolling at this width.
class LeaderboardCard extends StatelessWidget {
  const LeaderboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.accent,
    required this.rows,
    required this.overallTotal,
    required this.overallTotalLabel,
    required this.emptyLabel,
    required this.currency,
    this.viewAllLabel,
    this.onViewAll,
  });

  final String title;
  final IconData icon;
  final Color accent;
  final List<LeaderboardRow> rows;
  final double overallTotal;
  final String overallTotalLabel;
  final String emptyLabel;
  final NumberFormat currency;
  final String? viewAllLabel;
  final VoidCallback? onViewAll;

  static const _rankColors = [Color(0xFFD4AF37), Color(0xFFA8A8A8), Color(0xFFB08D57)];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
                  child: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (viewAllLabel != null && onViewAll != null)
                  TextButton(onPressed: onViewAll, child: Text(viewAllLabel!)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: EmptyView(message: emptyLabel, icon: Icons.leaderboard_outlined),
            )
          else ...[
            for (var i = 0; i < rows.length; i++) ...[
              _LeaderboardRowTile(
                rank: i + 1,
                row: rows[i],
                accent: i < 3 ? _rankColors[i] : scheme.onSurfaceVariant,
                currency: currency,
              ),
              if (i != rows.length - 1) const Divider(height: 1, indent: AppSpacing.md, endIndent: AppSpacing.md),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.07)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(overallTotalLabel, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: accent)),
                  Text(
                    currency.format(overallTotal),
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: accent),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LeaderboardRowTile extends StatelessWidget {
  const _LeaderboardRowTile({
    required this.rank,
    required this.row,
    required this.accent,
    required this.currency,
  });

  final int rank;
  final LeaderboardRow row;
  final Color accent;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isTopThree = rank <= 3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: isTopThree ? 0.18 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  row.project,
                  style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: (row.percentage / 100).clamp(0, 1).toDouble(),
                    minHeight: 4,
                    backgroundColor: scheme.surfaceContainerHighest,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currency.format(row.amount),
                style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                '${row.percentage.toStringAsFixed(1)}%',
                style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
