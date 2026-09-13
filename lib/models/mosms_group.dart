class MoSmsGroup {
  const MoSmsGroup({
    required this.id,
    required this.name,
    this.description,
    this.contactsCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory MoSmsGroup.fromJson(Map<String, dynamic> json) {
    return MoSmsGroup(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      contactsCount: (json['contacts_count'] as num?)?.toInt() ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  final int id;
  final String name;
  final String? description;
  final int contactsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
