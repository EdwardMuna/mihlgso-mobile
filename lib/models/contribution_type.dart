class ContributionType {
  const ContributionType({
    required this.id,
    required this.name,
    required this.amount,
    required this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ContributionType.fromJson(Map<String, dynamic> json) {
    return ContributionType(
      id: json['id'] as int,
      name: json['name'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  final int id;
  final String name;
  final double amount;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
