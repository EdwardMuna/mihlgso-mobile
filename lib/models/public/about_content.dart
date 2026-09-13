import 'label_value.dart';

class AboutHero {
  const AboutHero({required this.eyebrow, required this.title, required this.lead, required this.imageAlt});

  factory AboutHero.fromJson(Map<String, dynamic> json) => AboutHero(
        eyebrow: json['eyebrow'] as String? ?? '',
        title: json['title'] as String? ?? '',
        lead: json['lead'] as String? ?? '',
        imageAlt: json['imageAlt'] as String? ?? '',
      );

  final String eyebrow;
  final String title;
  final String lead;
  final String imageAlt;
}

class AboutValueItem {
  const AboutValueItem({required this.key, required this.title, required this.body});

  factory AboutValueItem.fromJson(Map<String, dynamic> json) => AboutValueItem(
        key: json['key'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String key;
  final String title;
  final String body;
}

class AboutNumberItem {
  const AboutNumberItem({required this.key, required this.label, required this.value});

  factory AboutNumberItem.fromJson(Map<String, dynamic> json) => AboutNumberItem(
        key: json['key'] as String? ?? '',
        label: json['label'] as String? ?? '',
        value: json['value'] as String? ?? '',
      );

  final String key;
  final String label;
  final String value;
}

class AboutContent {
  const AboutContent({
    required this.hero,
    required this.factsHeading,
    required this.facts,
    required this.preamble,
    required this.whoWeAre,
    required this.valuesHeading,
    required this.valuesSubheading,
    required this.values,
    required this.numbersHeading,
    required this.numbers,
    required this.whereWeWork,
    required this.whereWeWorkFacts,
    required this.explore,
    required this.cta,
  });

  factory AboutContent.fromJson(Map<String, dynamic> json) {
    final facts = json['facts'] as Map<String, dynamic>? ?? const {};
    final preamble = json['preamble'] as Map<String, dynamic>? ?? const {};
    final whoWeAre = json['whoWeAre'] as Map<String, dynamic>? ?? const {};
    final values = json['values'] as Map<String, dynamic>? ?? const {};
    final numbers = json['numbers'] as Map<String, dynamic>? ?? const {};
    final whereWeWork = json['whereWeWork'] as Map<String, dynamic>? ?? const {};
    final explore = json['explore'] as Map<String, dynamic>? ?? const {};
    final cta = json['cta'] as Map<String, dynamic>? ?? const {};

    return AboutContent(
      hero: AboutHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      factsHeading: facts['heading'] as String? ?? '',
      facts: ((facts['items'] as List<dynamic>?) ?? [])
          .map((e) => LabelValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      preamble: TitleBodyLike(
        heading: preamble['heading'] as String? ?? '',
        body: preamble['body'] as String? ?? '',
      ),
      whoWeAre: WhoWeAre(
        eyebrow: whoWeAre['eyebrow'] as String? ?? '',
        heading: whoWeAre['heading'] as String? ?? '',
        body1: whoWeAre['body1'] as String? ?? '',
        body2: whoWeAre['body2'] as String? ?? '',
        imageAlt: whoWeAre['imageAlt'] as String? ?? '',
      ),
      valuesHeading: values['heading'] as String? ?? '',
      valuesSubheading: values['subheading'] as String? ?? '',
      values: ((values['items'] as List<dynamic>?) ?? [])
          .map((e) => AboutValueItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      numbersHeading: numbers['heading'] as String? ?? '',
      numbers: ((numbers['items'] as List<dynamic>?) ?? [])
          .map((e) => AboutNumberItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      whereWeWork: WhoWeAre(
        eyebrow: whereWeWork['eyebrow'] as String? ?? '',
        heading: whereWeWork['heading'] as String? ?? '',
        body1: whereWeWork['body1'] as String? ?? '',
        body2: whereWeWork['body2'] as String? ?? '',
        imageAlt: whereWeWork['imageAlt'] as String? ?? '',
      ),
      whereWeWorkFacts: ((whereWeWork['facts'] as List<dynamic>?) ?? [])
          .map((e) => LabelValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      explore: ExploreSection(
        heading: explore['heading'] as String? ?? '',
        visionMission: TitleBody.fromJson(explore['visionMission'] as Map<String, dynamic>? ?? const {}),
        constitution: TitleBody.fromJson(explore['constitution'] as Map<String, dynamic>? ?? const {}),
        history: TitleBody.fromJson(explore['history'] as Map<String, dynamic>? ?? const {}),
      ),
      cta: CtaSection(
        eyebrow: cta['eyebrow'] as String? ?? '',
        heading: cta['heading'] as String? ?? '',
        body: cta['body'] as String? ?? '',
        primary: cta['primary'] as String? ?? '',
        secondary: cta['secondary'] as String? ?? '',
      ),
    );
  }

  final AboutHero hero;
  final String factsHeading;
  final List<LabelValue> facts;
  final TitleBodyLike preamble;
  final WhoWeAre whoWeAre;
  final String valuesHeading;
  final String valuesSubheading;
  final List<AboutValueItem> values;
  final String numbersHeading;
  final List<AboutNumberItem> numbers;
  final WhoWeAre whereWeWork;
  final List<LabelValue> whereWeWorkFacts;
  final ExploreSection explore;
  final CtaSection cta;
}

class TitleBodyLike {
  const TitleBodyLike({required this.heading, required this.body});
  final String heading;
  final String body;
}

class WhoWeAre {
  const WhoWeAre({
    required this.eyebrow,
    required this.heading,
    required this.body1,
    required this.body2,
    required this.imageAlt,
  });
  final String eyebrow;
  final String heading;
  final String body1;
  final String body2;
  final String imageAlt;
}

class ExploreSection {
  const ExploreSection({
    required this.heading,
    required this.visionMission,
    required this.constitution,
    required this.history,
  });
  final String heading;
  final TitleBody visionMission;
  final TitleBody constitution;
  final TitleBody history;
}

class CtaSection {
  const CtaSection({
    required this.eyebrow,
    required this.heading,
    required this.body,
    required this.primary,
    required this.secondary,
  });
  final String eyebrow;
  final String heading;
  final String body;
  final String primary;
  final String secondary;
}
