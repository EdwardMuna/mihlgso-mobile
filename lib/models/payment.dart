import 'contribution_type.dart';

enum PaymentStatus { notPaid, partial, paid }

PaymentStatus paymentStatusFromJson(String value) {
  switch (value) {
    case 'PAID':
      return PaymentStatus.paid;
    case 'PARTIAL':
      return PaymentStatus.partial;
    default:
      return PaymentStatus.notPaid;
  }
}

enum ApprovalStatus { pending, approved, rejected }

ApprovalStatus approvalStatusFromJson(String value) {
  switch (value) {
    case 'APPROVED':
      return ApprovalStatus.approved;
    case 'REJECTED':
      return ApprovalStatus.rejected;
    default:
      return ApprovalStatus.pending;
  }
}

class Payment {
  const Payment({
    required this.id,
    required this.paymentName,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    required this.approvalStatus,
    required this.paymentDate,
    this.contributionType,
    this.reference,
    this.notes,
    this.memberName,
    this.memberEmail,
    this.userId,
    this.contributionTypeId,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return Payment(
      id: json['id'] as int,
      paymentName: json['paymentName'] as String,
      amountDue: double.tryParse(json['amountDue'].toString()) ?? 0,
      amountPaid: double.tryParse(json['amountPaid'].toString()) ?? 0,
      status: paymentStatusFromJson(json['status'] as String),
      approvalStatus: approvalStatusFromJson(json['approvalStatus'] as String),
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      contributionType: json['contributionType'] != null
          ? ContributionType.fromJson(json['contributionType'] as Map<String, dynamic>)
          : null,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      memberName: user?['name'] as String?,
      memberEmail: user?['email'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      contributionTypeId: (json['contributionTypeId'] as num?)?.toInt(),
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'] as String) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }

  final int id;
  final String paymentName;
  final double amountDue;
  final double amountPaid;
  final PaymentStatus status;
  final ApprovalStatus approvalStatus;
  final DateTime paymentDate;
  final ContributionType? contributionType;
  final String? reference;
  final String? notes;
  final String? memberName;
  final String? memberEmail;
  final int? userId;
  final int? contributionTypeId;
  final DateTime? reviewedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Naive due-minus-paid for this row alone. Prefer [computeRunningRemaining]
  /// when a full payments list is available, since the website computes the
  /// remaining balance as a running total across a member's approved payments
  /// for the same contribution type, in chronological order.
  double get amountRemaining => (amountDue - amountPaid).clamp(0, double.infinity);
}

/// Mirrors the running-balance calculation from the website's
/// app/[locale]/admin/payments/page.tsx (lines ~103-135): walks ALL payments
/// (not just a filtered subset) ordered by paymentDate/id ascending, and for
/// each `userId:contributionTypeId` group accumulates `amountPaid` only for
/// APPROVED payments. A row's remaining balance is
/// `max(0, amountDue - runningPaidSoFarForThatGroup)`.
///
/// Returns a map of payment id -> remaining balance. Pass the full,
/// unfiltered list of payments (e.g. straight from the provider) — not a
/// search/status-filtered subset — so the running totals stay correct
/// regardless of what the UI currently has filtered/visible.
Map<int, double> computeRunningRemaining(List<Payment> allPayments) {
  final sorted = [...allPayments]..sort((a, b) {
      final byDate = a.paymentDate.compareTo(b.paymentDate);
      if (byDate != 0) return byDate;
      return a.id.compareTo(b.id);
    });

  final runningPaidByGroup = <String, double>{};
  final remainingById = <int, double>{};
  for (final p in sorted) {
    final key = '${p.userId}:${p.contributionTypeId}';
    var runningPaid = runningPaidByGroup[key] ?? 0;
    if (p.approvalStatus == ApprovalStatus.approved) {
      runningPaid += p.amountPaid;
      runningPaidByGroup[key] = runningPaid;
    }
    final remaining = p.amountDue - runningPaid;
    remainingById[p.id] = remaining < 0 ? 0 : remaining;
  }
  return remainingById;
}
