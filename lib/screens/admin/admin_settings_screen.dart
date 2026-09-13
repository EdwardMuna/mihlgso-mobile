import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/state_views.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  Future<void> _save(BuildContext context, WidgetRef ref, TextEditingController controller) async {
    final strings = AppStrings.of(context);
    final value = int.tryParse(controller.text.trim());
    if (value == null || value < 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.enterValidNonNegativeNumber)));
      return;
    }
    try {
      await ref.read(adminServiceProvider).updateOrgStats(value);
      ref.invalidate(adminOrgStatsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.settingsSaved)));
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final statsAsync = ref.watch(adminOrgStatsProvider);

    return statsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminOrgStatsProvider)),
        data: (stats) {
          final controller = TextEditingController(text: '${stats.beneficiariesCount}');
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(strings.organizationSettings, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.beneficiariesServedTitle),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: strings.totalBeneficiaries),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => _save(context, ref, controller),
                          child: Text(strings.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
    );
  }
}
