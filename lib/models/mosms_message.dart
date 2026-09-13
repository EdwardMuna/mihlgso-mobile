class MoSmsMessageUserRef {
  const MoSmsMessageUserRef({required this.id, this.name, this.email});

  factory MoSmsMessageUserRef.fromJson(Map<String, dynamic> json) {
    return MoSmsMessageUserRef(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  final int id;
  final String? name;
  final String? email;
}

class MoSmsMessage {
  const MoSmsMessage({
    required this.id,
    required this.toNumber,
    this.fromSender,
    required this.body,
    required this.status,
    this.displayStatus,
    this.deliveryStatus,
    this.deliveredAt,
    this.deliveryError,
    this.gatewayMessageId,
    this.sentAt,
    this.scheduledAt,
    this.createdAt,
    this.user,
  });

  factory MoSmsMessage.fromJson(Map<String, dynamic> json) {
    return MoSmsMessage(
      id: (json['id'] as num).toInt(),
      toNumber: json['to_number'] as String? ?? '',
      fromSender: json['from_sender'] as String?,
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      displayStatus: json['display_status'] as String?,
      deliveryStatus: json['delivery_status'] as String?,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'] as String) : null,
      deliveryError: json['delivery_error'] as String?,
      // The gateway sometimes returns this as a number rather than the
      // string the backend's own type declares — coerce defensively so a
      // send doesn't crash parsing its own response (seen in practice).
      gatewayMessageId: json['gateway_message_id']?.toString(),
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at'] as String) : null,
      scheduledAt: json['scheduled_at'] != null ? DateTime.tryParse(json['scheduled_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      user: json['user'] != null ? MoSmsMessageUserRef.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  final int id;
  final String toNumber;
  final String? fromSender;
  final String body;
  final String status;
  final String? displayStatus;
  final String? deliveryStatus;
  final DateTime? deliveredAt;
  final String? deliveryError;
  final String? gatewayMessageId;
  final DateTime? sentAt;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final MoSmsMessageUserRef? user;

  /// Mirrors the backend's `moSmsMessageChannel()` — WhatsApp gateway ids
  /// are prefixed `wamid.`; everything else is treated as SMS.
  bool get isWhatsapp => gatewayMessageId?.startsWith('wamid.') ?? false;
  String get channelLabel => isWhatsapp ? 'WhatsApp' : 'SMS';
}
