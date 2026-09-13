import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../models/mosms_gateway_log.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';

Color deliveryColor(BuildContext context, String delivery) {
  final scheme = Theme.of(context).colorScheme;
  switch (delivery.toUpperCase()) {
    case 'DELIVERED':
      return Colors.green;
    case 'PENDING':
      return Colors.orange;
    case 'FAILED':
    case 'EXPIRED':
    case 'REJECTED':
      return scheme.error;
    default:
      return scheme.outline;
  }
}

class MoSmsGatewayLogTile extends StatelessWidget {
  const MoSmsGatewayLogTile({super.key, required this.log});
  final MoSmsGatewayLog log;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(log.to, style: Theme.of(context).textTheme.titleMedium)),
                Chip(
                  label: Text(log.statusName ?? log.delivery),
                  backgroundColor: deliveryColor(context, log.delivery).withValues(alpha: 0.15),
                  labelStyle: TextStyle(color: deliveryColor(context, log.delivery)),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            if (log.reference.isNotEmpty) Text('${strings.refPrefix}: ${log.reference}'),
            Text('${strings.sentPrefix}: ${log.sentAt.isEmpty ? '—' : log.sentAt}'),
            Text('${strings.donePrefix}: ${log.doneAt ?? '—'}'),
            Text('${strings.smsCountPrefix}: ${log.smsCount}'),
          ],
        ),
      ),
    );
  }
}

class MoSmsSmsLogsScreen extends ConsumerWidget {
  const MoSmsSmsLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final logsAsync = ref.watch(mosmsSmsLogsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.smsLogs)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(mosmsSmsLogsProvider),
        child: logsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsSmsLogsProvider)),
          data: (logs) {
            if (logs.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noSmsLogsFound, icon: Icons.receipt_long_outlined),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 26),
              itemCount: logs.length,
              itemBuilder: (context, i) => MoSmsGatewayLogTile(log: logs[i]),
            );
          },
        ),
      ),
    );
  }
}
