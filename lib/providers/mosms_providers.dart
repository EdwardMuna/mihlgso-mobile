import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/mosms_balance.dart';
import '../models/mosms_contact.dart';
import '../models/mosms_gateway_log.dart';
import '../models/mosms_group.dart';
import '../models/mosms_message.dart';
import '../models/mosms_paginated.dart';
import '../models/mosms_template.dart';
import '../services/mosms_service.dart';
import 'core_providers.dart';

final mosmsServiceProvider = Provider<MoSmsService>((ref) {
  return MoSmsService(ref.watch(apiClientProvider));
});

final mosmsBalanceProvider = FutureProvider.autoDispose<MoSmsBalance>((ref) {
  return ref.watch(mosmsServiceProvider).fetchBalance();
});

/// Filters for the contacts list — kept simple (single string) since the
/// only server-side filter is a free-text search.
final mosmsContactsProvider =
    FutureProvider.autoDispose.family<MoSmsPaginated<MoSmsContact>, String>((ref, search) {
  return ref.watch(mosmsServiceProvider).fetchContacts(search: search);
});

final mosmsGroupsProvider = FutureProvider.autoDispose<MoSmsPaginated<MoSmsGroup>>((ref) {
  return ref.watch(mosmsServiceProvider).fetchGroups();
});

final mosmsGroupProvider = FutureProvider.autoDispose.family<MoSmsGroup, int>((ref, id) {
  return ref.watch(mosmsServiceProvider).fetchGroup(id);
});

final mosmsGroupContactsProvider =
    FutureProvider.autoDispose.family<MoSmsPaginated<MoSmsContact>, int>((ref, groupId) {
  return ref.watch(mosmsServiceProvider).fetchGroupContacts(groupId);
});

class MoSmsMessageFilter {
  const MoSmsMessageFilter({this.status, this.search, this.dateFrom, this.dateTo});
  final String? status;
  final String? search;
  final String? dateFrom;
  final String? dateTo;

  @override
  bool operator ==(Object other) =>
      other is MoSmsMessageFilter &&
      other.status == status &&
      other.search == search &&
      other.dateFrom == dateFrom &&
      other.dateTo == dateTo;

  @override
  int get hashCode => Object.hash(status, search, dateFrom, dateTo);
}

final mosmsMessagesProvider =
    FutureProvider.autoDispose.family<MoSmsPaginated<MoSmsMessage>, MoSmsMessageFilter>((ref, filter) {
  return ref.watch(mosmsServiceProvider).fetchMessages(
        status: filter.status,
        search: filter.search,
        dateFrom: filter.dateFrom,
        dateTo: filter.dateTo,
      );
});

final mosmsMessageProvider = FutureProvider.autoDispose.family<MoSmsMessage, int>((ref, id) {
  return ref.watch(mosmsServiceProvider).fetchMessage(id);
});

final mosmsTemplatesProvider = FutureProvider.autoDispose<MoSmsPaginated<MoSmsTemplate>>((ref) {
  return ref.watch(mosmsServiceProvider).fetchTemplates();
});

final mosmsScheduledMessagesProvider =
    FutureProvider.autoDispose<MoSmsPaginated<MoSmsMessage>>((ref) {
  return ref.watch(mosmsServiceProvider).fetchMessages(status: 'scheduled');
});

final mosmsSmsLogsProvider = FutureProvider.autoDispose<List<MoSmsGatewayLog>>((ref) {
  return ref.watch(mosmsServiceProvider).fetchSmsLogs();
});

final mosmsDeliveryReportsProvider =
    FutureProvider.autoDispose.family<List<MoSmsGatewayLog>, String>((ref, messageId) {
  return ref.watch(mosmsServiceProvider).fetchDeliveryReports(messageId: messageId);
});
