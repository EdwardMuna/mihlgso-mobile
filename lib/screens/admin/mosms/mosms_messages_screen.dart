import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/mosms_message.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import 'mosms_send_screen.dart';

class MoSmsMessagesScreen extends ConsumerStatefulWidget {
  const MoSmsMessagesScreen({super.key, this.flashMessage});

  /// Shown as a snackbar right after this screen mounts — used when landing
  /// here straight after sending a message, since a snackbar queued on the
  /// screen being popped away from is not reliably visible.
  final String? flashMessage;

  @override
  ConsumerState<MoSmsMessagesScreen> createState() => _MoSmsMessagesScreenState();
}

class _MoSmsMessagesScreenState extends ConsumerState<MoSmsMessagesScreen> {
  String? _status;

  @override
  void initState() {
    super.initState();
    final message = widget.flashMessage;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      });
    }
  }

  static final _timeFmt = DateFormat('d MMM, HH:mm');

  Widget _statusIndicator(BuildContext context, MoSmsMessage m) {
    final scheme = Theme.of(context).colorScheme;
    final status = (m.displayStatus ?? m.status).toLowerCase();
    // Match exact known codes, not a loose substring — "delivering"/
    // "in transit" (submitted to carrier, not yet confirmed) contains
    // "deliver" too and must NOT count as delivered. "Delivered" can land on
    // either the send-time status (status/display_status) or the separate
    // delivery report (delivery_status, carrier DLR codes like "DELIVRD") —
    // check both fields, but only accept an unambiguous confirmed/failed word.
    String normalize(String s) => s.replaceAll(RegExp('[^a-z]'), '');
    final statuses = [normalize(status), if (m.deliveryStatus != null) normalize(m.deliveryStatus!.toLowerCase())];
    const deliveredCodes = {'delivered', 'delivrd'};
    const failedCodes = {'failed', 'undeliv', 'undelivered', 'rejectd', 'rejected', 'expired'};
    final deliveryFailed = statuses.any(failedCodes.contains);
    final delivered = !deliveryFailed && statuses.any(deliveredCodes.contains);

    final Widget icon;
    if (status == 'failed' || deliveryFailed) {
      icon = Icon(Icons.error_outline, size: 16, color: scheme.error);
    } else if (status == 'pending' || status == 'scheduled') {
      icon = Icon(Icons.schedule, size: 16, color: scheme.onSurfaceVariant);
    } else if (delivered) {
      // Double tick: confirmed delivered.
      icon = Icon(Icons.done_all, size: 16, color: AppColors.secondary);
    } else {
      // Single tick: sent, but no delivery confirmation yet.
      icon = Icon(Icons.done, size: 16, color: scheme.onSurfaceVariant);
    }

    // .toLocal() matters: if the gateway returns sent_at as UTC (with a
    // Z/offset suffix), DateFormat renders the DateTime's own clock fields
    // verbatim — without this it would show literal UTC time instead of the
    // device's local time (3h off for Tanzania/EAT). A no-op if the string
    // had no offset info to begin with (DateTime.tryParse then already
    // treats it as local).
    final time = (m.sentAt ?? m.scheduledAt ?? m.createdAt)?.toLocal();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        icon,
        if (time != null) ...[
          const SizedBox(height: 4),
          Text(_timeFmt.format(time), style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final filter = MoSmsMessageFilter(status: _status);
    final messagesAsync = ref.watch(mosmsMessagesProvider(filter));

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.messagesTitle),
        actions: [
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (v) => setState(() => _status = v),
            itemBuilder: (context) => [
              PopupMenuItem(value: null, child: Text(strings.filterAll)),
              PopupMenuItem(value: 'sent', child: Text(strings.filterSent)),
              PopupMenuItem(value: 'delivered', child: Text(strings.filterDelivered)),
              PopupMenuItem(value: 'failed', child: Text(strings.filterFailed)),
              PopupMenuItem(value: 'pending', child: Text(strings.filterPending)),
              PopupMenuItem(value: 'scheduled', child: Text(strings.filterScheduled)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: strings.newMessageTooltip,
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MoSmsSendScreen(lockMode: MoSmsSendMode.single, title: strings.newMessageTooltip)),
        ).then((_) => ref.invalidate(mosmsMessagesProvider(MoSmsMessageFilter(status: _status)))),
        child: const Icon(Icons.message_outlined),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mosmsMessagesProvider(filter)),
        child: messagesAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsMessagesProvider(filter))),
          data: (page) {
            if (page.data.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noMessagesYet, icon: Icons.forum_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 14),
              itemCount: page.data.length,
              itemBuilder: (context, i) {
                final m = page.data[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(m.toNumber),
                  subtitle: Text(m.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: _statusIndicator(context, m),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MoSmsMessageDetailScreen(messageId: m.id)),
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

class MoSmsMessageDetailScreen extends ConsumerWidget {
  const MoSmsMessageDetailScreen({super.key, required this.messageId});
  final int messageId;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(mosmsServiceProvider).cancelMessage(messageId);
      ref.invalidate(mosmsMessageProvider(messageId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _checkStatus(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(mosmsServiceProvider).checkMessageStatus(messageId);
      ref.invalidate(mosmsMessageProvider(messageId));
    } on ApiException catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final messageAsync = ref.watch(mosmsMessageProvider(messageId));
    final dateFmt = DateFormat.yMMMd().add_jm();

    return Scaffold(
      appBar: AppBar(title: Text(strings.messageDetailsTitle)),
      body: messageAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsMessageProvider(messageId))),
        data: (m) => ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
          children: [
            ListTile(leading: const Icon(Icons.phone_outlined), title: Text(strings.toLabel), subtitle: Text(m.toNumber)),
            ListTile(
              leading: Icon(m.isWhatsapp ? Icons.chat_outlined : Icons.sms_outlined),
              title: Text(strings.channelLabel),
              subtitle: Text(m.channelLabel),
            ),
            ListTile(leading: const Icon(Icons.message_outlined), title: Text(strings.messageLabel), subtitle: Text(m.body)),
            ListTile(leading: const Icon(Icons.info_outline), title: Text(strings.status), subtitle: Text(m.displayStatus ?? m.status)),
            if (m.deliveryStatus != null)
              ListTile(leading: const Icon(Icons.local_shipping_outlined), title: Text(strings.deliveryLabel), subtitle: Text(m.deliveryStatus!)),
            if (m.deliveryError != null)
              ListTile(
                leading: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                title: Text(strings.deliveryErrorLabel),
                subtitle: Text(m.deliveryError!),
              ),
            if (m.sentAt != null) ListTile(leading: const Icon(Icons.send_outlined), title: Text(strings.sentAtLabel), subtitle: Text(dateFmt.format(m.sentAt!.toLocal()))),
            if (m.scheduledAt != null)
              ListTile(leading: const Icon(Icons.schedule_outlined), title: Text(strings.scheduledAtLabel), subtitle: Text(dateFmt.format(m.scheduledAt!.toLocal()))),
            if (m.user != null)
              ListTile(leading: const Icon(Icons.person_outline), title: Text(strings.sentByLabel), subtitle: Text(m.user!.name ?? m.user!.email ?? '')),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _checkStatus(context, ref),
                    icon: const Icon(Icons.refresh),
                    label: Text(strings.checkStatusButton),
                  ),
                ),
                if (m.scheduledAt != null && m.status.toLowerCase() != 'sent') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                      onPressed: () => _cancel(context, ref),
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(strings.cancel),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
