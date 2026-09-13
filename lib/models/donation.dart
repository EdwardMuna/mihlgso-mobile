import 'payment.dart' show ApprovalStatus, approvalStatusFromJson;

class Donation {
  const Donation({
    required this.id,
    required this.donorName,
    required this.amount,
    required this.approvalStatus,
    required this.donatedAt,
    this.purpose,
    this.reference,
    this.notes,
    this.donorEmail,
    this.donorPhone,
    this.memberName,
    this.memberEmail,
    this.userId,
    this.reviewedAt,
    this.createdAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Donation(
      id: json['id'] as int,
      donorName: json['donorName'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      approvalStatus: approvalStatusFromJson(json['approvalStatus'] as String),
      donatedAt: DateTime.parse(json['donatedAt'] as String),
      purpose: json['purpose'] as String?,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      donorEmail: json['donorEmail'] as String?,
      donorPhone: json['donorPhone'] as String?,
      memberName: user?['name'] as String?,
      memberEmail: user?['email'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
    );
  }

  final int id;
  final String donorName;
  final double amount;
  final ApprovalStatus approvalStatus;
  final DateTime donatedAt;
  final String? purpose;
  final String? reference;
  final String? notes;
  final String? donorEmail;
  final String? donorPhone;
  final String? memberName;
  final String? memberEmail;
  final int? userId;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
}
