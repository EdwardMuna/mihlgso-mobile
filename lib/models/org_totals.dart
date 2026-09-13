/// Org-wide transparency figures shown on the member dashboard — the same
/// aggregate totals admins see on their own dashboard, sourced from
/// GET /api/org-totals (member-accessible, unlike the full admin org-stats).
class OrgTotals {
  const OrgTotals({required this.totalPaid, required this.totalDonated});

  factory OrgTotals.fromJson(Map<String, dynamic> json) {
    return OrgTotals(
      totalPaid: double.tryParse(json['totalPaid'].toString()) ?? 0,
      totalDonated: double.tryParse(json['totalDonated'].toString()) ?? 0,
    );
  }

  final double totalPaid;
  final double totalDonated;
}
