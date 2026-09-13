import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import 'mosms_sms_logs_screen.dart';

class MoSmsDeliveryReportsScreen extends ConsumerStatefulWidget {
  const MoSmsDeliveryReportsScreen({super.key});

  @override
  ConsumerState<MoSmsDeliveryReportsScreen> createState() => _MoSmsDeliveryReportsScreenState();
}

class _MoSmsDeliveryReportsScreenState extends ConsumerState<MoSmsDeliveryReportsScreen> {
  final _controller = TextEditingController();
  String _messageId = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final reportsAsync = ref.watch(mosmsDeliveryReportsProvider(_messageId));

    return Scaffold(
      appBar: AppBar(title: Text(strings.deliveryReports)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: strings.filterByMessageId,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (v) => setState(() => _messageId = v.trim()),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(mosmsDeliveryReportsProvider(_messageId)),
              child: reportsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) =>
                    ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsDeliveryReportsProvider(_messageId))),
                data: (logs) {
                  if (logs.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyView(message: strings.noDeliveryReportsFound, icon: Icons.local_shipping_outlined),
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
          ),
        ],
      ),
    );
  }
}
