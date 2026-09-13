import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../models/mosms_contact.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';

class MoSmsContactsScreen extends ConsumerStatefulWidget {
  const MoSmsContactsScreen({super.key});

  @override
  ConsumerState<MoSmsContactsScreen> createState() => _MoSmsContactsScreenState();
}

class _MoSmsContactsScreenState extends ConsumerState<MoSmsContactsScreen> {
  final _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showContactForm(MoSmsContact? existing) async {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController(text: existing?.name ?? '');
    final phoneController = TextEditingController(text: existing?.phone ?? '');
    final emailController = TextEditingController(text: existing?.email ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? strings.addContact : strings.editContact),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: strings.name)),
            TextField(controller: phoneController, decoration: InputDecoration(labelText: strings.phone), keyboardType: TextInputType.phone),
            TextField(controller: emailController, decoration: InputDecoration(labelText: strings.emailOptional)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.save)),
        ],
      ),
    );
    if (saved != true) return;
    try {
      final service = ref.read(mosmsServiceProvider);
      if (existing == null) {
        await service.createContact(
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        );
      } else {
        await service.updateContact(
          existing.id,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
        );
      }
      ref.invalidate(mosmsContactsProvider);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _delete(MoSmsContact contact) async {
    final strings = AppStrings.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.deleteContactTitle),
        content: Text(strings.removeContactMessage(contact.name)),
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
      await ref.read(mosmsServiceProvider).deleteContact(contact.id);
      ref.invalidate(mosmsContactsProvider);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final contactsAsync = ref.watch(mosmsContactsProvider(_search));

    return Scaffold(
      appBar: AppBar(title: Text(strings.contacts)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactForm(null),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: strings.searchContacts,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (v) => setState(() => _search = v.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(mosmsContactsProvider(_search)),
              child: contactsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsContactsProvider(_search))),
                data: (page) {
                  if (page.data.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyView(message: strings.noContactsFound, icon: Icons.contacts_outlined),
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
                        subtitle: Text(
                          c.email != null && c.email!.isNotEmpty ? '${c.phone} · ${c.email}' : c.phone,
                        ),
                        onTap: () => _showContactForm(c),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(c),
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
