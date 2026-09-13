/// Raw gateway record shared by the SMS Logs and Delivery Reports pages —
/// mirrors the third-party MoSMS gateway's `/sms-logs` and
/// `/delivery-reports` response shape verbatim.
class MoSmsGatewayLog {
  const MoSmsGatewayLog({
    required this.messageId,
    required this.reference,
    required this.sentAt,
    this.doneAt,
    required this.to,
    required this.from,
    required this.smsCount,
    this.statusName,
    required this.delivery,
  });

  factory MoSmsGatewayLog.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as Map<String, dynamic>?;
    return MoSmsGatewayLog(
      messageId: json['messageId'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      sentAt: json['sentAt'] as String? ?? '',
      doneAt: json['doneAt'] as String?,
      to: json['to'] as String? ?? '',
      from: json['from'] as String? ?? '',
      smsCount: (json['smsCount'] as num?)?.toInt() ?? 0,
      statusName: status?['name'] as String?,
      delivery: json['delivery'] as String? ?? '',
    );
  }

  final String messageId;
  final String reference;
  final String sentAt;
  final String? doneAt;
  final String to;
  final String from;
  final int smsCount;
  final String? statusName;
  final String delivery;
}
