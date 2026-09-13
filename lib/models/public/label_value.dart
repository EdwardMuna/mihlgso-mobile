/// Shared shape for the many `{label, value}` / `{title, body}` pairs the
/// public-content API routes return.
class LabelValue {
  const LabelValue({required this.label, required this.value});

  factory LabelValue.fromJson(Map<String, dynamic> json) {
    return LabelValue(
      label: json['label'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  final String label;
  final String value;
}

class TitleBody {
  const TitleBody({required this.title, required this.body});

  factory TitleBody.fromJson(Map<String, dynamic> json) {
    return TitleBody(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

  final String title;
  final String body;
}
