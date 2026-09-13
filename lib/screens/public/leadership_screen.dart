import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/leader_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';
import 'leadership_board_screen.dart';
import 'leadership_executive_screen.dart';
import 'leadership_departments_screen.dart';

enum _LeadershipSection { overview, board, executive, departments }

class LeadershipScreen extends ConsumerWidget {
  const LeadershipScreen({super.key});

  void _onSelectSection(BuildContext context, _LeadershipSection section) {
    switch (section) {
      case _LeadershipSection.overview:
        break;
      case _LeadershipSection.board:
        context.push('/leadership/board');
        break;
      case _LeadershipSection.executive:
        context.push('/leadership/executive');
        break;
      case _LeadershipSection.departments:
        context.push('/leadership/departments');
        break;
    }
  }

  void _openGroup(BuildContext context, String key) {
    switch (key) {
      case 'board':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeadershipBoardScreen()));
        break;
      case 'executive':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeadershipExecutiveScreen()));
        break;
      case 'departments':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeadershipDepartmentsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadershipAsync = ref.watch(leadershipProvider);
    final textTheme = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.leadershipTitle),
        actions: [
          PopupMenuButton<_LeadershipSection>(
            icon: const Icon(Icons.expand_more),
            tooltip: strings.leadershipSectionsTooltip,
            onSelected: (section) => _onSelectSection(context, section),
            itemBuilder: (context) => [
              PopupMenuItem(value: _LeadershipSection.overview, child: Text(strings.overview)),
              PopupMenuItem(value: _LeadershipSection.board, child: Text(strings.board)),
              PopupMenuItem(value: _LeadershipSection.executive, child: Text(strings.executive)),
              PopupMenuItem(value: _LeadershipSection.departments, child: Text(strings.departments)),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(leadershipProvider),
        child: leadershipAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(leadershipProvider)),
          data: (content) {
            final grouped = <String, List<int>>{};
            for (var i = 0; i < content.leaders.length; i++) {
              grouped.putIfAbsent(content.leaders[i].group, () => []).add(i);
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(content.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(content.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: 20),

                if (content.leaders.isEmpty && content.openRoles.isEmpty)
                  EmptyView(message: strings.noLeadershipProfilesYet, icon: Icons.groups_outlined)
                else ...[
                  for (final group in grouped.keys) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(group, style: textTheme.titleMedium),
                    ),
                    for (final i in grouped[group]!) LeaderCard(member: content.leaders[i]),
                  ],
                  if (content.openRoles.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(strings.openRoles, style: textTheme.titleMedium),
                    ),
                    for (final role in content.openRoles)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.person_add_alt_outlined),
                          title: Text(role.role),
                          subtitle: Text(role.group),
                        ),
                      ),
                  ],
                ],

                const SizedBox(height: AppSpacing.lg),
                for (final group in content.groups)
                  Card(
                    child: ListTile(
                      title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(group.intro),
                      trailing: TextButton(
                        onPressed: () => _openGroup(context, group.key),
                        child: Text(group.viewLink),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),
                Text(content.structureTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.structureLead, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final layer in content.structureLayers)
                  Card(
                    child: ListTile(
                      title: Text(layer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${layer.role}\n${layer.body}'),
                      isThreeLine: true,
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.agmTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.agmBody),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),
                Text(content.principlesTitle, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.principlesLead, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final principle in content.principles)
                  Card(child: ListTile(title: Text(principle.title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(principle.body))),

                const SizedBox(height: AppSpacing.lg),
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.joinCtaTitle, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.joinCtaBody),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            OutlinedButton(onPressed: () => context.push('/contact'), child: Text(content.joinCtaPrimary)),
                            const SizedBox(width: AppSpacing.sm),
                            FilledButton(onPressed: () => context.push('/apply'), child: Text(content.joinCtaSecondary)),
                          ],
                        ),
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
