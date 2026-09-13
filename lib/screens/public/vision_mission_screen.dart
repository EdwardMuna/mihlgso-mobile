import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class VisionMissionScreen extends ConsumerWidget {
  const VisionMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(visionMissionProvider);
    final textTheme = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.visionMission)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(visionMissionProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(visionMissionProvider)),
          data: (content) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(content.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(content.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.vision.label, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(content.vision.article, style: textTheme.labelMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.vision.body),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.mission.label, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        Text(content.mission.article, style: textTheme.labelMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.mission.body),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(content.objectivesHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.objectivesSubheading, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                for (final entry in content.objectives.asMap().entries)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${entry.key + 1}')),
                      title: Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.value.body),
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
