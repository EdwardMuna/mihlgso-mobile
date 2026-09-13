import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import 'mosms_messages_screen.dart';

class MoSmsScheduledScreen extends ConsumerStatefulWidget {
  const MoSmsScheduledScreen({super.key});

  @override
  ConsumerState<MoSmsScheduledScreen> createState() => _MoSmsScheduledScreenState();
}

class _MoSmsScheduledScreenState extends ConsumerState<MoSmsScheduledScreen> {
  Future<void> _scheduleMessage() async {
    final strings = AppStrings.of(context);
    final toController = TextEditingController();
    final textController = TextEditingController();
    DateTime? scheduledAt;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.scheduleMessageTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: toController,
                  decoration: InputDecoration(labelText: strings.toPhoneNumber),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: textController,
                  decoration: InputDecoration(labelText: strings.messageLabel),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        scheduledAt == null ? strings.noDateTimeSelected : DateFormat.yMMMd().add_jm().format(scheduledAt!),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date == null || !context.mounted) return;
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time == null) return;
                        setState(() {
                          scheduledAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                        });
                      },
                      child: Text(strings.pickButton),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(strings.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(strings.scheduleButton)),
          ],
        ),
      ),
    );
    if (confirmed != true) return;

    final to = toController.text.trim();
    final text = textController.text.trim();
    if (to.isEmpty || text.isEmpty || scheduledAt == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.scheduleValidationMessage)));
      }
      return;
    }
    try {
      await ref.read(mosmsServiceProvider).sendSingle(to: to, text: text, scheduledAt: scheduledAt!.toIso8601String());
      ref.invalidate(mosmsScheduledMessagesProvider);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final messagesAsync = ref.watch(mosmsScheduledMessagesProvider);
    final dateFmt = DateFormat.yMMMd().add_jm();

    return Scaffold(
      appBar: AppBar(title: Text(strings.scheduledMessages)),
      floatingActionButton: FloatingActionButton(
        onPressed: _scheduleMessage,
        child: const Icon(Icons.add_alarm),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mosmsScheduledMessagesProvider),
        child: messagesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsScheduledMessagesProvider)),
          data: (page) {
            if (page.data.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noScheduledMessages, icon: Icons.schedule_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 14),
              itemCount: page.data.length,
              itemBuilder: (context, i) {
                final m = page.data[i];
                return ListTile(
                  leading: Icon(m.isWhatsapp ? Icons.chat_outlined : Icons.sms_outlined),
                  title: Text(m.toNumber),
                  subtitle: Text(
                    [
                      m.body,
                      if (m.scheduledAt != null) 'Scheduled ${dateFmt.format(m.scheduledAt!)}',
                    ].join('\n'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: Chip(label: Text(m.displayStatus ?? m.status), visualDensity: VisualDensity.compact),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MoSmsMessageDetailScreen(messageId: m.id)),
                  ).then((_) => ref.invalidate(mosmsScheduledMessagesProvider)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
