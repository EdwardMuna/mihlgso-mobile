import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/leader_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class LeadershipExecutiveScreen extends ConsumerWidget {
  const LeadershipExecutiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(leadershipExecutiveProvider);
    final textTheme = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.executive)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(leadershipExecutiveProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(leadershipExecutiveProvider)),
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
                if (content.members.isEmpty)
                  EmptyView(message: strings.noExecutiveMembersYet, icon: Icons.groups_outlined)
                else
                  for (final member in content.members) LeaderCard(member: member),
                if (content.compositionNote != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(content.compositionNote!, style: textTheme.bodySmall),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(content.dutiesTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.dutiesLead, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final duty in content.duties)
                  Card(
                    child: ListTile(
                      title: Text(duty.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(duty.body),
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
