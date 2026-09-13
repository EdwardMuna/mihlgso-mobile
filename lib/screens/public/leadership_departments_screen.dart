import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class LeadershipDepartmentsScreen extends ConsumerWidget {
  const LeadershipDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leadershipDepartmentsProvider);
    final textTheme = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.departments)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(leadershipDepartmentsProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(leadershipDepartmentsProvider)),
          data: (content) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(content.hero.eyebrow, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(content.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(content.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                for (final dept in content.departments)
                  Card(child: ListTile(title: Text(dept.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(dept.body))),
                const SizedBox(height: AppSpacing.lg),
                Text(content.detailTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.detailLead, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final detail in content.details)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(detail.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          Text(detail.focusLabel, style: textTheme.labelSmall),
                          const SizedBox(height: 6),
                          for (final point in detail.focus)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•  '),
                                  Expanded(child: Text(point)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.governanceTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.governanceBody),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const AppFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}
