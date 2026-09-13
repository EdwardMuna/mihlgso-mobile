import '../core/network/api_client.dart';
import '../models/mosms_balance.dart';
import '../models/mosms_contact.dart';
import '../models/mosms_gateway_log.dart';
import '../models/mosms_group.dart';
import '../models/mosms_message.dart';
import '../models/mosms_paginated.dart';
import '../models/mosms_template.dart';

/// Wraps /api/admin/mosms/* — thin admin-only proxies to the third-party
/// MoSMS SaaS gateway. Every list response follows the gateway's own
/// `{data, meta}` pagination shape; mutation responses vary per endpoint
/// (see each method) and are passed straight through by the backend.
class MoSmsService {
  MoSmsService(this._client);

  final ApiClient _client;

  Future<MoSmsBalance> fetchBalance() async {
    final json = await _client.get('/admin/mosms/balance');
    return MoSmsBalance.fromJson(json);
  }

  // ---- Contacts ----

  Future<MoSmsPaginated<MoSmsContact>> fetchContacts({String? search, int page = 1}) async {
    final json = await _client.get('/admin/mosms/contacts', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page,
    });
    return MoSmsPaginated.fromJson(json, MoSmsContact.fromJson);
  }

  Future<MoSmsContact> createContact({
    required String name,
    required String phone,
    String? email,
    String? birthDate,
  }) async {
    final json = await _client.post('/admin/mosms/contacts', data: {
      'name': name,
      'phone': phone,
      if (email != null && email.isNotEmpty) 'email': email,
      if (birthDate != null && birthDate.isNotEmpty) 'birth_date': birthDate,
    });
    return MoSmsContact.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<MoSmsContact> updateContact(
    int id, {
    String? name,
    String? phone,
    String? email,
    String? birthDate,
  }) async {
    final json = await _client.patch('/admin/mosms/contacts/$id', data: {
      'name': ?name,
      'phone': ?phone,
      'email': ?email,
      'birth_date': ?birthDate,
    });
    return MoSmsContact.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> deleteContact(int id) async {
    await _client.delete('/admin/mosms/contacts/$id');
  }

  // ---- Groups ----

  Future<MoSmsPaginated<MoSmsGroup>> fetchGroups({int page = 1}) async {
    final json = await _client.get('/admin/mosms/groups', query: {'page': page});
    return MoSmsPaginated.fromJson(json, MoSmsGroup.fromJson);
  }

  Future<MoSmsGroup> createGroup({required String name, String? description}) async {
    final json = await _client.post('/admin/mosms/groups', data: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
    });
    return MoSmsGroup.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<MoSmsGroup> fetchGroup(int id) async {
    final json = await _client.get('/admin/mosms/groups/$id');
    return MoSmsGroup.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<MoSmsGroup> updateGroup(int id, {String? name, String? description}) async {
    final json = await _client.patch('/admin/mosms/groups/$id', data: {
      'name': ?name,
      'description': ?description,
    });
    return MoSmsGroup.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> deleteGroup(int id) async {
    await _client.delete('/admin/mosms/groups/$id');
  }

  Future<MoSmsPaginated<MoSmsContact>> fetchGroupContacts(int groupId, {int page = 1}) async {
    final json = await _client.get('/admin/mosms/groups/$groupId/contacts', query: {'page': page});
    return MoSmsPaginated.fromJson(json, MoSmsContact.fromJson);
  }

  Future<void> addContactsToGroup(int groupId, List<int> contactIds) async {
    await _client.post('/admin/mosms/groups/$groupId/contacts', data: {'contact_ids': contactIds});
  }

  Future<void> removeContactsFromGroup(int groupId, List<int> contactIds) async {
    await _client.delete('/admin/mosms/groups/$groupId/contacts', data: {'contact_ids': contactIds});
  }

  // ---- Messages ----

  Future<MoSmsPaginated<MoSmsMessage>> fetchMessages({
    String? status,
    String? search,
    String? dateFrom,
    String? dateTo,
    int page = 1,
  }) async {
    final json = await _client.get('/admin/mosms/messages', query: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
      if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
      if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
      'page': page,
    });
    return MoSmsPaginated.fromJson(json, MoSmsMessage.fromJson);
  }

  Future<MoSmsMessage> fetchMessage(int id) async {
    final json = await _client.get('/admin/mosms/messages/$id');
    return MoSmsMessage.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> cancelMessage(int id) async {
    await _client.post('/admin/mosms/messages/$id/cancel');
  }

  Future<MoSmsMessage> checkMessageStatus(int id) async {
    final json = await _client.post('/admin/mosms/messages/$id/check-status');
    return MoSmsMessage.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Returns the number of messages deleted.
  Future<int> deleteMessages(List<int> ids) async {
    final json = await _client.delete('/admin/mosms/messages', data: {'ids': ids});
    return (json['count'] as num?)?.toInt() ?? ids.length;
  }

  // ---- Send ----

  Future<MoSmsMessage> sendSingle({required String to, required String text, String? scheduledAt}) async {
    final json = await _client.post('/admin/mosms/send', data: {
      'to': to,
      'text': text,
      'scheduled_at': ?scheduledAt,
    });
    return MoSmsMessage.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Returns the number of messages queued.
  Future<int> sendBulk({required List<Map<String, String>> messages, String? scheduledAt}) async {
    final json = await _client.post('/admin/mosms/send-bulk', data: {
      'messages': messages,
      'scheduled_at': ?scheduledAt,
    });
    return (json['count'] as num?)?.toInt() ?? messages.length;
  }

  /// Returns the number of group contacts the message was sent to.
  Future<int> sendToGroup(int groupId, {required String text, String? scheduledAt}) async {
    final json = await _client.post('/admin/mosms/send-group/$groupId', data: {
      'text': text,
      'scheduled_at': ?scheduledAt,
    });
    return (json['contacts'] as num?)?.toInt() ?? 0;
  }

  // ---- Templates ----

  Future<MoSmsPaginated<MoSmsTemplate>> fetchTemplates({int page = 1}) async {
    final json = await _client.get('/admin/mosms/templates', query: {'page': page});
    return MoSmsPaginated.fromJson(json, MoSmsTemplate.fromJson);
  }

  Future<MoSmsTemplate> createTemplate({required String name, required String body}) async {
    final json = await _client.post('/admin/mosms/templates', data: {'name': name, 'body': body});
    return MoSmsTemplate.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<MoSmsTemplate> updateTemplate(int id, {required String name, required String body}) async {
    final json = await _client.patch('/admin/mosms/templates/$id', data: {'name': name, 'body': body});
    return MoSmsTemplate.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> deleteTemplate(int id) async {
    await _client.delete('/admin/mosms/templates/$id');
  }

  // ---- Logs / Delivery Reports ----

  Future<List<MoSmsGatewayLog>> fetchSmsLogs() async {
    final json = await _client.get('/admin/mosms/sms-logs');
    final list = json['results'] as List<dynamic>? ?? [];
    return list.map((e) => MoSmsGatewayLog.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MoSmsGatewayLog>> fetchDeliveryReports({String? messageId}) async {
    final json = await _client.get('/admin/mosms/delivery-reports', query: {
      if (messageId != null && messageId.isNotEmpty) 'messageId': messageId,
    });
    final list = json['results'] as List<dynamic>? ?? [];
    return list.map((e) => MoSmsGatewayLog.fromJson(e as Map<String, dynamic>)).toList();
  }
}
