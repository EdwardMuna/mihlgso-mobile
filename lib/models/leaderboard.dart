/// One row of the "Top Contributors"/"Top Donors" leaderboards — mirrors
/// lib/leaderboards.ts's LeaderboardRow on the website.
class LeaderboardRow {
  const LeaderboardRow({
    required this.id,
    required this.name,
    required this.project,
    required this.amount,
    required this.percentage,
  });

  factory LeaderboardRow.fromJson(Map<String, dynamic> json) {
    return LeaderboardRow(
      id: json['id'] as String,
      name: json['name'] as String,
      project: json['project'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0,
      percentage: double.tryParse(json['percentage'].toString()) ?? 0,
    );
  }

  final String id;
  final String name;
  final String project;
  final double amount;
  final double percentage;
}

class LeaderboardResult {
  const LeaderboardResult({required this.rows, required this.total});

  factory LeaderboardResult.fromJson(Map<String, dynamic> json) {
    final list = json['rows'] as List<dynamic>? ?? [];
    return LeaderboardResult(
      rows: list.map((e) => LeaderboardRow.fromJson(e as Map<String, dynamic>)).toList(),
      total: double.tryParse(json['total'].toString()) ?? 0,
    );
  }

  final List<LeaderboardRow> rows;
  final double total;
}
