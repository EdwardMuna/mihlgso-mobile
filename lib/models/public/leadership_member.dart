class LeadershipMember {
  const LeadershipMember({
    required this.id,
    required this.group,
    required this.name,
    required this.role,
    required this.photo,
    this.bio,
  });

  factory LeadershipMember.fromJson(Map<String, dynamic> json) {
    return LeadershipMember(
      id: json['id']?.toString() ?? '',
      group: json['group'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      photo: json['photo'] as String? ?? '',
      bio: json['bio'] as String?,
    );
  }

  final String id;
  final String group;
  final String name;
  final String role;
  final String photo;
  final String? bio;
}

class LeadershipOpenRole {
  const LeadershipOpenRole({required this.group, required this.role});

  factory LeadershipOpenRole.fromJson(Map<String, dynamic> json) {
    return LeadershipOpenRole(
      group: json['group'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  final String group;
  final String role;
}
