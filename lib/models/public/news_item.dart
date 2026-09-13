class NewsItem {
  const NewsItem({
    required this.id,
    required this.date,
    required this.type,
    required this.title,
    required this.summary,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id']?.toString() ?? '',
      date: json['date'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
    );
  }

  final String id;
  final String date;
  final String type;
  final String title;
  final String summary;
}
