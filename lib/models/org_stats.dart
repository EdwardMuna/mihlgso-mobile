class OrgStats {
  const OrgStats({
    required this.beneficiariesCount,
    required this.memberCount,
    required this.donorCount,
    required this.pendingApplications,
    required this.totalPaid,
    required this.totalDonated,
    required this.contributionTypesCount,
    required this.pendingApprovals,
  });

  factory OrgStats.fromJson(Map<String, dynamic> json) {
    return OrgStats(
      beneficiariesCount: (json['beneficiariesCount'] as num?)?.toInt() ?? 0,
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 0,
      donorCount: (json['donorCount'] as num?)?.toInt() ?? 0,
      pendingApplications: (json['pendingApplications'] as num?)?.toInt() ?? 0,
      totalPaid: double.tryParse(json['totalPaid'].toString()) ?? 0,
      totalDonated: double.tryParse(json['totalDonated'].toString()) ?? 0,
      contributionTypesCount: (json['contributionTypesCount'] as num?)?.toInt() ?? 0,
      pendingApprovals: (json['pendingApprovals'] as num?)?.toInt() ?? 0,
    );
  }

  final int beneficiariesCount;
  final int memberCount;
  final int donorCount;
  final int pendingApplications;
  final double totalPaid;
  final double totalDonated;
  final int contributionTypesCount;
  final int pendingApprovals;
}
