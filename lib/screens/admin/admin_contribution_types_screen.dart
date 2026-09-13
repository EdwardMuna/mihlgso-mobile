import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/localization/app_strings.dart';
import '../../core/network/api_exception.dart';
import '../../models/contribution_type.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/state_views.dart';

class AdminContributionTypesScreen extends ConsumerWidget {
  const AdminContributionTypesScreen({super.key});

  Future<void> _showEditor(BuildContext context, WidgetRef ref, {ContributionType? existing}) async {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final amountController = TextEditingController(text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final descController = TextEditingController(text: existing?.description ?? '');
    bool isActive = existing?.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? strings.newContributionType : strings.editContributionType),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: InputDecoration(labelText: strings.name)),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: strings.amountTsh),
                ),
                TextField(controller: descController, decoration: InputDecoration(labelText: strings.descriptionOptional)),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.active),
                  value: isActive,
                  onChanged: (v) => setState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.save)),
          ],
        ),
      ),
    );
    if (saved != true) return;

    final name = nameController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final description = descController.text.trim();
    if (name.isEmpty || amount <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.enterValidNameAmount)));
      }
      return;
    }

    try {
      if (existing == null) {
        await ref.read(adminServiceProvider).createContributionType(
              name: name,
              amount: amount,
              description: description.isEmpty ? null : description,
              isActive: isActive,
            );
      } else {
        await ref.read(adminServiceProvider).updateContributionType(
              existing.id,
              name: name,
              amount: amount,
              description: description.isEmpty ? null : description,
              isActive: isActive,
            );
      }
      ref.invalidate(adminContributionTypesProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ContributionType type) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteContributionTypeTitle),
        content: Text(strings.deleteContributionTypeMessage(type.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminServiceProvider).deleteContributionType(type.id);
      ref.invalidate(adminContributionTypesProvider);
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final typesAsync = ref.watch(adminContributionTypesProvider);
    final currency = NumberFormat.currency(locale: 'en_TZ', symbol: 'TSh ', decimalDigits: 0);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditor(context, ref),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminContributionTypesProvider),
        child: typesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(adminContributionTypesProvider)),
          data: (types) {
            if (types.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noContributionTypesYet, icon: Icons.category_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: types.length,
              itemBuilder: (context, i) {
                final t = types[i];
                return Card(
                  child: ListTile(
                    title: Text(t.name),
                    subtitle: Text([
                      currency.format(t.amount),
                      if (t.description != null && t.description!.isNotEmpty) t.description!,
                      if (!t.isActive) strings.inactive,
                      if (t.createdAt != null) '${strings.addedPrefix} ${DateFormat.yMMMd().format(t.createdAt!)}',
                    ].join(' · ')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _showEditor(context, ref, existing: t),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(context, ref, t),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
