class MoSmsContactGroupRef {
  const MoSmsContactGroupRef({required this.id, required this.name});

  factory MoSmsContactGroupRef.fromJson(Map<String, dynamic> json) {
    return MoSmsContactGroupRef(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
    );
  }

  final int id;
  final String name;
}

class MoSmsContact {
  const MoSmsContact({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.birthDate,
    this.groups = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory MoSmsContact.fromJson(Map<String, dynamic> json) {
    final groupsList = json['groups'] as List<dynamic>?;
    return MoSmsContact(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      birthDate: json['birth_date'] as String?,
      groups: groupsList
              ?.map((e) => MoSmsContactGroupRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? birthDate;
  final List<MoSmsContactGroupRef> groups;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
