import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/mosms_group.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import 'mosms_group_detail_screen.dart';
import 'mosms_group_members_picker_screen.dart';

class MoSmsGroupsScreen extends ConsumerWidget {
  const MoSmsGroupsScreen({super.key});

  Future<void> _showGroupForm(BuildContext context, WidgetRef ref, MoSmsGroup? existing) async {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final descController = TextEditingController(text: existing?.description ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? strings.newGroup : strings.editGroup),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: strings.name)),
            TextField(controller: descController, decoration: InputDecoration(labelText: strings.descriptionOptional)),
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
    try {
      final service = ref.read(mosmsServiceProvider);
      if (existing == null) {
        final group = await service.createGroup(name: name, description: descController.text.trim());
        ref.invalidate(mosmsGroupsProvider);
        // Straight into picking/adding members — mirrors the request to be
        // able to build a group either from existing Contacts or by adding
        // new name/phone entries on the spot, right after creating it.
        if (context.mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MoSmsGroupMembersPickerScreen(groupId: group.id, groupName: group.name)),
          );
        }
      } else {
        await service.updateGroup(existing.id, name: name, description: descController.text.trim());
      }
      ref.invalidate(mosmsGroupsProvider);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, MoSmsGroup group) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteGroupTitle),
        content: Text(strings.removeGroupMessage(group.name)),
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
      await ref.read(mosmsServiceProvider).deleteGroup(group.id);
      ref.invalidate(mosmsGroupsProvider);
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final groupsAsync = ref.watch(mosmsGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.groupsNav)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGroupForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mosmsGroupsProvider),
        child: groupsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsGroupsProvider)),
          data: (page) {
            if (page.data.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noGroupsYet, icon: Icons.groups_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 14),
              itemCount: page.data.length,
              itemBuilder: (context, i) {
                final g = page.data[i];
                return ListTile(
                  title: Text(g.name),
                  subtitle: Text('${g.contactsCount} contacts${g.description != null && g.description!.isNotEmpty ? ' · ${g.description}' : ''}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MoSmsGroupDetailScreen(groupId: g.id)),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) => v == 'edit' ? _showGroupForm(context, ref, g) : _delete(context, ref, g),
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(strings.editMenuItem)),
                      PopupMenuItem(value: 'delete', child: Text(strings.delete)),
                    ],
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
