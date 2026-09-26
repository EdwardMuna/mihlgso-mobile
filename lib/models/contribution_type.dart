class ContributionType {
  const ContributionType({
    required this.id,
    required this.name,
    required this.amount,
    required this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.bankName,
    this.bankAccountName,
    this.bankAccountNumber,
    this.bankBranch,
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
      bankName: json['bankName'] as String?,
      bankAccountName: json['bankAccountName'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankBranch: json['bankBranch'] as String?,
    );
  }

  final int id;
  final String name;
  final double amount;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? bankName;
  final String? bankAccountName;
  final String? bankAccountNumber;
  final String? bankBranch;

  bool get hasBankAccount =>
      (bankName?.trim().isNotEmpty ?? false) || (bankAccountNumber?.trim().isNotEmpty ?? false);
}
