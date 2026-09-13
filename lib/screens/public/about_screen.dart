import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/state_views.dart';

enum _AboutSection { aboutMihlgso, visionMission, history, constitution }

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  void _onSelectSection(BuildContext context, _AboutSection section) {
    switch (section) {
      case _AboutSection.aboutMihlgso:
        break;
      case _AboutSection.visionMission:
        context.push('/about/vision-mission');
        break;
      case _AboutSection.history:
        context.push('/about/history');
        break;
      case _AboutSection.constitution:
        context.push('/about/constitution');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutAsync = ref.watch(aboutContentProvider);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.aboutUsTitle),
        actions: [
          PopupMenuButton<_AboutSection>(
            icon: const Icon(Icons.expand_more),
            tooltip: strings.aboutSectionsTooltip,
            onSelected: (section) => _onSelectSection(context, section),
            itemBuilder: (context) => [
              PopupMenuItem(value: _AboutSection.aboutMihlgso, child: Text(strings.aboutMihlgso)),
              PopupMenuItem(value: _AboutSection.visionMission, child: Text(strings.visionMission)),
              PopupMenuItem(value: _AboutSection.history, child: Text(strings.history)),
              PopupMenuItem(value: _AboutSection.constitution, child: Text(strings.constitution)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(aboutContentProvider),
        child: aboutAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(aboutContentProvider)),
          data: (about) {
            final textTheme = Theme.of(context).textTheme;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(about.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(about.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                if (about.facts.isNotEmpty) ...[
                  Text(about.factsHeading, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Card(
                    child: Column(
                      children: [
                        for (final fact in about.facts) ...[
                          ListTile(dense: true, title: Text(fact.label), trailing: Text(fact.value)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(about.preamble.heading, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(about.preamble.body),
                const SizedBox(height: 20),
                Text(about.whoWeAre.heading, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(about.whoWeAre.body1),
                const SizedBox(height: AppSpacing.sm),
                Text(about.whoWeAre.body2),
                const SizedBox(height: 20),
                if (about.values.isNotEmpty) ...[
                  Text(about.valuesHeading, style: textTheme.titleMedium),
                  Text(about.valuesSubheading, style: textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.sm),
                  for (final v in about.values)
                    Card(child: ListTile(title: Text(v.title), subtitle: Text(v.body))),
                  const SizedBox(height: 20),
                ],
                if (about.numbers.isNotEmpty) ...[
                  Text(about.numbersHeading, style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.6,
                    children: [
                      for (final n in about.numbers)
                        Card(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(n.value, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                Text(n.label, style: textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                Text(about.whereWeWork.heading, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(about.whereWeWork.body1),
                const SizedBox(height: AppSpacing.sm),
                Text(about.whereWeWork.body2),
                if (about.whereWeWorkFacts.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  for (final fact in about.whereWeWorkFacts)
                    ListTile(dense: true, title: Text(fact.label), trailing: Text(fact.value)),
                ],
                const SizedBox(height: 20),
                Text(about.explore.heading, style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  child: ListTile(
                    title: Text(about.explore.visionMission.title),
                    subtitle: Text(about.explore.visionMission.body),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/about/vision-mission'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text(about.explore.constitution.title),
                    subtitle: Text(about.explore.constitution.body),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/about/constitution'),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text(about.explore.history.title),
                    subtitle: Text(about.explore.history.body),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/about/history'),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(about.cta.heading, style: textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(about.cta.body),
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
