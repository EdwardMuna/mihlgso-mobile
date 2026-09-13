import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/mosms_providers.dart';
import '../../../widgets/state_views.dart';
import '../../../widgets/tinted_stat_card.dart';
import 'mosms_contacts_screen.dart';
import 'mosms_delivery_reports_screen.dart';
import 'mosms_groups_screen.dart';
import 'mosms_inbox_screen.dart';
import 'mosms_messages_screen.dart';
import 'mosms_scheduled_screen.dart';
import 'mosms_send_screen.dart';
import 'mosms_sms_logs_screen.dart';
import 'mosms_templates_screen.dart';

class MoSmsHomeScreen extends ConsumerWidget {
  const MoSmsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppStrings.of(context);
    final balanceAsync = ref.watch(mosmsBalanceProvider);

    return RefreshIndicator(
        onRefresh: () async => ref.invalidate(mosmsBalanceProvider),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            balanceAsync.when(
              loading: () => const SizedBox(height: 100, child: LoadingView()),
              error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(mosmsBalanceProvider)),
              data: (balance) => Row(
                children: [
                  Expanded(
                    child: TintedStatCard(
                      label: strings.smsBalance,
                      value: '${balance.smsBalance}',
                      icon: Icons.sms_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TintedStatCard(
                      label: strings.whatsappBalance,
                      value: '${balance.whatsappBalance}',
                      icon: Icons.chat_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Mirrors the website's MoSMS sidebar section order exactly:
            // Messages, Scheduled, Inbox, Bulk SMS, Group SMS, SMS Logs,
            // Delivery Reports, then a MANAGE group (Contacts, Groups,
            // Templates).
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(strings.messagesNav),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsMessagesScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: Text(strings.scheduledNav),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsScheduledScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.inbox_outlined),
                    title: Text(strings.inbox),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsInboxScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.forum_outlined),
                    title: Text(strings.bulkSms),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MoSmsSendScreen(lockMode: MoSmsSendMode.bulk, title: strings.bulkSms)),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.groups_2_outlined),
                    title: Text(strings.groupSms),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MoSmsSendScreen(lockMode: MoSmsSendMode.group, title: strings.groupSms)),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text(strings.smsLogs),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsSmsLogsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.local_shipping_outlined),
                    title: Text(strings.deliveryReports),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsDeliveryReportsScreen())),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
              child: Text(strings.manageSectionHeader, style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.1)),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.contacts_outlined),
                    title: Text(strings.contacts),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsContactsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.groups_outlined),
                    title: Text(strings.groupsNav),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsGroupsScreen())),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(strings.templates),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoSmsTemplatesScreen())),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
