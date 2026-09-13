import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  Widget _bulletList(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('•  '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(membershipProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.membership)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(membershipProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(membershipProvider)),
          data: (content) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(content.hero.eyebrow, style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(content.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(content.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () => context.push('/apply'),
                  child: Text(content.hero.applyButton),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.push('/membership/status'),
                  child: Text(strings.checkApplicationStatus),
                ),

                const SizedBox(height: AppSpacing.lg),
                Text(content.typesHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.typesSubheading, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                for (final type in content.types)
                  Card(child: ListTile(title: Text(type.name, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(type.body))),

                const SizedBox(height: AppSpacing.lg),
                Text(content.benefitsHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.benefitsSubheading, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final benefit in content.benefits)
                  Card(child: ListTile(title: Text(benefit.title, style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text(benefit.body))),

                const SizedBox(height: AppSpacing.lg),
                Text(content.tiers.heading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.tiers.subheading, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final row in content.tiers.rows)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.name, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(content.tiers.eligibilityLabel, style: textTheme.labelSmall),
                          Text(row.eligibility),
                          const SizedBox(height: 6),
                          Text(content.tiers.feeLabel, style: textTheme.labelSmall),
                          Text(row.fee),
                          const SizedBox(height: 6),
                          Text(content.tiers.rightsLabel, style: textTheme.labelSmall),
                          Text(row.rights),
                          const SizedBox(height: 6),
                          Text(content.tiers.approvalLabel, style: textTheme.labelSmall),
                          Text(row.approval),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(content.tiers.feeNote, style: textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),

                const SizedBox(height: AppSpacing.lg),
                Text(content.rightsHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.rightsSubheading, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                _bulletList(context, content.rights),

                const SizedBox(height: AppSpacing.lg),
                Text(content.dutiesHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.dutiesSubheading, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                _bulletList(context, content.duties),

                const SizedBox(height: AppSpacing.lg),
                Text(content.terminationHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.terminationSubheading, style: textTheme.bodySmall),
                const SizedBox(height: AppSpacing.sm),
                _bulletList(context, content.termination),

                const SizedBox(height: AppSpacing.lg),
                Text(content.howToApply.heading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.howToApply.subheading, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final entry in content.howToApply.steps.asMap().entries)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(child: Text('${entry.key + 1}')),
                      title: Text(entry.value.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(entry.value.body),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(onPressed: () => context.push('/apply'), child: Text(content.howToApply.cta)),

                const SizedBox(height: AppSpacing.lg),
                Text(content.faq.heading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.faq.subheading, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                for (final item in content.faq.items)
                  Card(
                    child: ExpansionTile(
                      title: Text(item.question, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(alignment: Alignment.centerLeft, child: Text(item.answer)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),
                Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(content.applyCta.heading, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.applyCta.body),
                        const SizedBox(height: 12),
                        FilledButton(onPressed: () => context.push('/apply'), child: Text(content.applyCta.button)),
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
