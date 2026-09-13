import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/mosms_template.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import 'mosms_messages_screen.dart';

/// Single / Bulk / To-Group sending, all reachable from one screen via a
/// segmented control. If [prefillGroupId] is set (opened from a group's
/// detail screen), starts on the "To Group" mode with that group selected.
class MoSmsSendScreen extends ConsumerStatefulWidget {
  const MoSmsSendScreen({super.key, this.prefillGroupId, this.lockMode, this.title});
  final int? prefillGroupId;

  /// When set, the segmented mode switcher is hidden and the screen is
  /// pinned to this mode — used by the dedicated "Bulk SMS" / "Group SMS"
  /// menu entries that mirror the website's separate pages for each.
  final MoSmsSendMode? lockMode;
  final String? title;

  @override
  ConsumerState<MoSmsSendScreen> createState() => _MoSmsSendScreenState();
}

enum MoSmsSendMode { single, bulk, group }

class _MoSmsSendScreenState extends ConsumerState<MoSmsSendScreen> {
  late MoSmsSendMode _mode = widget.lockMode ?? (widget.prefillGroupId != null ? MoSmsSendMode.group : MoSmsSendMode.single);
  final _toController = TextEditingController();
  final _textController = TextEditingController();
  final _bulkController = TextEditingController();
  int? _selectedGroupId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.prefillGroupId;
  }

  @override
  void dispose() {
    _toController.dispose();
    _textController.dispose();
    _bulkController.dispose();
    super.dispose();
  }

  Future<void> _pickTemplate() async {
    final strings = AppStrings.of(context);
    final List<MoSmsTemplate> templates;
    try {
      // .future awaits the actual fetch instead of grabbing whatever's
      // already cached — mosmsTemplatesProvider is autoDispose, so if the
      // Templates screen was never opened first, a plain ref.read() here
      // would just see it mid-flight (or freshly disposed) and read as
      // empty, showing "No templates yet." even though the backend has
      // real templates (the same ones the website's Templates page lists).
      final result = await ref.read(mosmsTemplatesProvider.future);
      templates = result.data;
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      return;
    }
    if (templates.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.noTemplatesYetSnack)));
      }
      return;
    }
    if (!mounted) return;
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final t in templates)
              ListTile(title: Text(t.name), subtitle: Text(t.body, maxLines: 1, overflow: TextOverflow.ellipsis), onTap: () => Navigator.pop(context, t.body)),
          ],
        ),
      ),
    );
    if (chosen != null) setState(() => _textController.text = chosen);
  }

  Future<void> _send() async {
    final strings = AppStrings.of(context);
    setState(() => _sending = true);
    try {
      final service = ref.read(mosmsServiceProvider);
      String flashMessage;
      switch (_mode) {
        case MoSmsSendMode.single:
          if (_toController.text.trim().isEmpty || _textController.text.trim().isEmpty) return;
          await service.sendSingle(to: _toController.text.trim(), text: _textController.text.trim());
          flashMessage = strings.messageSentSnack;
          break;
        case MoSmsSendMode.bulk:
          final lines = _bulkController.text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty);
          final messages = lines
              .map((line) {
                final parts = line.split('|');
                if (parts.length < 2) return null;
                return {'to': parts[0].trim(), 'text': parts.sublist(1).join('|').trim()};
              })
              .whereType<Map<String, String>>()
              .toList();
          if (messages.isEmpty) return;
          final count = await service.sendBulk(messages: messages);
          flashMessage = strings.messageSentQueuedSnack(count);
          break;
        case MoSmsSendMode.group:
          if (_selectedGroupId == null || _textController.text.trim().isEmpty) return;
          final contacts = await service.sendToGroup(_selectedGroupId!, text: _textController.text.trim());
          flashMessage = strings.messageSentToContactsSnack(contacts);
          break;
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MoSmsMessagesScreen(flashMessage: flashMessage)),
        );
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final groupsAsync = ref.watch(mosmsGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? strings.sendMessageTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.lockMode == null) ...[
              SegmentedButton<MoSmsSendMode>(
                segments: [
                  ButtonSegment(value: MoSmsSendMode.single, label: Text(strings.singleTab)),
                  ButtonSegment(value: MoSmsSendMode.bulk, label: Text(strings.bulkTab)),
                  ButtonSegment(value: MoSmsSendMode.group, label: Text(strings.toGroupTab)),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_mode == MoSmsSendMode.single) ...[
              TextField(
                controller: _toController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: strings.toPhoneNumber, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(labelText: strings.messageLabel, border: const OutlineInputBorder()),
              ),
            ],
            if (_mode == MoSmsSendMode.bulk) ...[
              TextField(
                controller: _bulkController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: strings.onePerLineHint,
                  helperText: strings.onePerLineExample,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
            if (_mode == MoSmsSendMode.group) ...[
              groupsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsGroupsProvider)),
                data: (page) => DropdownButtonFormField<int>(
                  initialValue: _selectedGroupId,
                  decoration: InputDecoration(labelText: strings.groupLabel, border: const OutlineInputBorder()),
                  items: page.data.map((g) => DropdownMenuItem(value: g.id, child: Text('${g.name} (${g.contactsCount})'))).toList(),
                  onChanged: (v) => setState(() => _selectedGroupId = v),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _textController,
                maxLines: 4,
                decoration: InputDecoration(labelText: strings.messageLabel, border: const OutlineInputBorder()),
              ),
            ],
            if (_mode != MoSmsSendMode.bulk) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _pickTemplate,
                  icon: const Icon(Icons.description_outlined),
                  label: Text(strings.useTemplate),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(height: AppSpacing.md, width: AppSpacing.md, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_outlined),
              label: Text(strings.sendButton),
            ),
          ],
        ),
      ),
    );
  }
}
