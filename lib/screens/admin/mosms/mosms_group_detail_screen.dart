import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/mosms_contact.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import 'mosms_group_members_picker_screen.dart';
import 'mosms_send_screen.dart';

class MoSmsGroupDetailScreen extends ConsumerWidget {
  const MoSmsGroupDetailScreen({super.key, required this.groupId});
  final int groupId;

  Future<void> _addContacts(BuildContext context, WidgetRef ref, String groupName) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MoSmsGroupMembersPickerScreen(groupId: groupId, groupName: groupName)),
    );
  }

  Future<void> _removeContact(BuildContext context, WidgetRef ref, MoSmsContact contact) async {
    try {
      await ref.read(mosmsServiceProvider).removeContactsFromGroup(groupId, [contact.id]);
      ref.invalidate(mosmsGroupContactsProvider(groupId));
      ref.invalidate(mosmsGroupProvider(groupId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final groupAsync = ref.watch(mosmsGroupProvider(groupId));
    final contactsAsync = ref.watch(mosmsGroupContactsProvider(groupId));
    final groupName = groupAsync.valueOrNull?.name ?? strings.groupFallbackTitle;

    return Scaffold(
      appBar: AppBar(
        title: groupAsync.when(
          data: (g) => Text(g.name),
          loading: () => Text(strings.groupFallbackTitle),
          error: (_, _) => Text(strings.groupFallbackTitle),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MoSmsSendScreen(prefillGroupId: groupId)),
        ),
        icon: const Icon(Icons.send_outlined),
        label: Text(strings.messageGroupButton),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: OutlinedButton.icon(
              onPressed: () => _addContacts(context, ref, groupName),
              icon: const Icon(Icons.person_add_alt_outlined),
              label: Text(strings.addMembersButton),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(mosmsGroupContactsProvider(groupId)),
              child: contactsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsGroupContactsProvider(groupId))),
                data: (page) {
                  if (page.data.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyView(message: strings.noContactsInGroupYet, icon: Icons.person_off_outlined),
                      ],
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 14),
                    itemCount: page.data.length,
                    itemBuilder: (context, i) {
                      final c = page.data[i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text(c.phone),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove_outlined),
                          onPressed: () => _removeContact(context, ref, c),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
