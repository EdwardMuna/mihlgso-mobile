import 'label_value.dart';

class SectionHero {
  const SectionHero({
    required this.eyebrow,
    required this.title,
    required this.lead,
  });

  factory SectionHero.fromJson(Map<String, dynamic> json) => SectionHero(
        eyebrow: json['eyebrow'] as String? ?? '',
        title: json['title'] as String? ?? '',
        lead: json['lead'] as String? ?? '',
      );

  final String eyebrow;
  final String title;
  final String lead;
}

class VisionMissionStatement {
  const VisionMissionStatement({
    required this.label,
    required this.article,
    required this.body,
  });

  factory VisionMissionStatement.fromJson(Map<String, dynamic> json) => VisionMissionStatement(
        label: json['label'] as String? ?? '',
        article: json['article'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String label;
  final String article;
  final String body;
}

class VisionMissionContent {
  const VisionMissionContent({
    required this.hero,
    required this.vision,
    required this.mission,
    required this.objectivesHeading,
    required this.objectivesSubheading,
    this.objectives = const [],
  });

  factory VisionMissionContent.fromJson(Map<String, dynamic> json) {
    final objectivesList = json['objectives'] as List<dynamic>? ?? [];
    return VisionMissionContent(
      hero: SectionHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      vision: VisionMissionStatement.fromJson(json['vision'] as Map<String, dynamic>? ?? const {}),
      mission: VisionMissionStatement.fromJson(json['mission'] as Map<String, dynamic>? ?? const {}),
      objectivesHeading: json['objectivesHeading'] as String? ?? '',
      objectivesSubheading: json['objectivesSubheading'] as String? ?? '',
      objectives: objectivesList.map((e) => TitleBody.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final SectionHero hero;
  final VisionMissionStatement vision;
  final VisionMissionStatement mission;
  final String objectivesHeading;
  final String objectivesSubheading;
  final List<TitleBody> objectives;
}

class HistoryEvent {
  const HistoryEvent({
    required this.year,
    required this.date,
    required this.title,
    required this.body,
  });

  factory HistoryEvent.fromJson(Map<String, dynamic> json) => HistoryEvent(
        year: json['year'] as String? ?? '',
        date: json['date'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String year;
  final String date;
  final String title;
  final String body;
}

class HistoryContent {
  const HistoryContent({
    required this.hero,
    required this.timelineHeading,
    this.events = const [],
  });

  factory HistoryContent.fromJson(Map<String, dynamic> json) {
    final eventsList = json['events'] as List<dynamic>? ?? [];
    return HistoryContent(
      hero: SectionHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      timelineHeading: json['timelineHeading'] as String? ?? '',
      events: eventsList.map((e) => HistoryEvent.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final SectionHero hero;
  final String timelineHeading;
  final List<HistoryEvent> events;
}

class ConstitutionPart {
  const ConstitutionPart({
    required this.id,
    required this.title,
    required this.articles,
    required this.body,
  });

  factory ConstitutionPart.fromJson(Map<String, dynamic> json) => ConstitutionPart(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        articles: json['articles'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String id;
  final String title;
  final String articles;
  final String body;
}

class ConstitutionContent {
  const ConstitutionContent({
    required this.hero,
    required this.downloadButton,
    required this.downloadHint,
    required this.pdfUrl,
    this.parts = const [],
  });

  factory ConstitutionContent.fromJson(Map<String, dynamic> json) {
    final hero = json['hero'] as Map<String, dynamic>? ?? const {};
    final partsList = json['parts'] as List<dynamic>? ?? [];
    return ConstitutionContent(
      hero: SectionHero.fromJson(hero),
      downloadButton: hero['downloadButton'] as String? ?? '',
      downloadHint: hero['downloadHint'] as String? ?? '',
      pdfUrl: json['pdfUrl'] as String? ?? '',
      parts: partsList.map((e) => ConstitutionPart.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final SectionHero hero;
  final String downloadButton;
  final String downloadHint;
  final String pdfUrl;
  final List<ConstitutionPart> parts;
}
