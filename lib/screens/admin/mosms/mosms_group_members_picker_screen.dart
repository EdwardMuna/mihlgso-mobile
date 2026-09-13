import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/mosms_contact.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';

/// Add members to a group either by picking (checkbox-selecting) from the
/// existing Contacts list, or by adding someone brand new by name/phone —
/// both feed into the same "selected" set and get added to the group
/// together when Done is pressed.
class MoSmsGroupMembersPickerScreen extends ConsumerStatefulWidget {
  const MoSmsGroupMembersPickerScreen({super.key, required this.groupId, required this.groupName});
  final int groupId;
  final String groupName;

  @override
  ConsumerState<MoSmsGroupMembersPickerScreen> createState() => _MoSmsGroupMembersPickerScreenState();
}

class _MoSmsGroupMembersPickerScreenState extends ConsumerState<MoSmsGroupMembersPickerScreen> {
  final _searchController = TextEditingController();
  String _search = '';
  final Set<int> _selectedIds = {};
  bool _saving = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addNewContact() async {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.addNewContactTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: strings.name)),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: strings.phone), keyboardType: TextInputType.phone),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.addButton)),
        ],
      ),
    );
    if (created != true) return;
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    try {
      final contact = await ref.read(mosmsServiceProvider).createContact(name: name, phone: phone);
      ref.invalidate(mosmsContactsProvider(_search));
      setState(() => _selectedIds.add(contact.id));
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _done() async {
    if (_selectedIds.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(mosmsServiceProvider).addContactsToGroup(widget.groupId, _selectedIds.toList());
      ref.invalidate(mosmsGroupContactsProvider(widget.groupId));
      ref.invalidate(mosmsGroupProvider(widget.groupId));
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final contactsAsync = ref.watch(mosmsContactsProvider(_search));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.addToGroupTitle(widget.groupName)),
        actions: [
          TextButton(
            onPressed: _saving ? null : _done,
            child: _saving
                ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    _selectedIds.isEmpty ? strings.doneButton : strings.addWithCount(_selectedIds.length),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewContact,
        icon: const Icon(Icons.person_add_alt_outlined),
        label: Text(strings.newContactButton),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: strings.searchContacts,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (v) => setState(() => _search = v.trim()),
              onChanged: (v) => setState(() => _search = v.trim()),
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsContactsProvider(_search))),
              data: (page) {
                if (page.data.isEmpty) {
                  return ListView(
                    children: [
                      const SizedBox(height: 80),
                      EmptyView(
                        message: _search.isEmpty
                            ? strings.noContactsYetTapNew
                            : strings.noContactsMatchSearch(_search),
                        icon: Icons.contacts_outlined,
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: page.data.length,
                  itemBuilder: (context, i) {
                    final MoSmsContact c = page.data[i];
                    final selected = _selectedIds.contains(c.id);
                    final alreadyInGroup = c.groups.any((g) => g.id == widget.groupId);
                    return CheckboxListTile(
                      value: alreadyInGroup ? true : selected,
                      onChanged: alreadyInGroup
                          ? null
                          : (v) => setState(() {
                                if (v == true) {
                                  _selectedIds.add(c.id);
                                } else {
                                  _selectedIds.remove(c.id);
                                }
                              }),
                      title: Text(c.name),
                      subtitle: Text(alreadyInGroup ? '${c.phone} · already in this group' : c.phone),
                      secondary: const Icon(Icons.person_outline),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
