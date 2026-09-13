class MoSmsTemplate {
  const MoSmsTemplate({
    required this.id,
    required this.name,
    required this.body,
    this.createdAt,
  });

  factory MoSmsTemplate.fromJson(Map<String, dynamic> json) {
    return MoSmsTemplate(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
    );
  }

  final int id;
  final String name;
  final String body;
  final DateTime? createdAt;
}
