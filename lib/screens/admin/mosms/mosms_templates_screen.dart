import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/mosms_template.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';

class MoSmsTemplatesScreen extends ConsumerWidget {
  const MoSmsTemplatesScreen({super.key});

  Future<void> _showForm(BuildContext context, WidgetRef ref, MoSmsTemplate? existing) async {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final bodyController = TextEditingController(text: existing?.body ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? strings.newTemplate : strings.editTemplate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: strings.name)),
            TextField(controller: bodyController, decoration: InputDecoration(labelText: strings.messageBodyLabel), maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.save)),
        ],
      ),
    );
    if (saved != true) return;
    final name = nameController.text.trim();
    final body = bodyController.text.trim();
    if (name.isEmpty || body.isEmpty) return;
    try {
      final service = ref.read(mosmsServiceProvider);
      if (existing == null) {
        await service.createTemplate(name: name, body: body);
      } else {
        await service.updateTemplate(existing.id, name: name, body: body);
      }
      ref.invalidate(mosmsTemplatesProvider);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MoSmsTemplate template) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteTemplateTitle),
        content: Text(strings.removeTemplateMessage(template.name)),
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
      await ref.read(mosmsServiceProvider).deleteTemplate(template.id);
      ref.invalidate(mosmsTemplatesProvider);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final templatesAsync = ref.watch(mosmsTemplatesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.templates)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mosmsTemplatesProvider),
        child: templatesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsTemplatesProvider)),
          data: (page) {
            if (page.data.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noTemplatesYet, icon: Icons.description_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 14),
              itemCount: page.data.length,
              itemBuilder: (context, i) {
                final t = page.data[i];
                return ListTile(
                  title: Text(t.name),
                  subtitle: Text(t.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                  onTap: () => _showForm(context, ref, t),
                  trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, ref, t)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
