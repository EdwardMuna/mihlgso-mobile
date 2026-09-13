import 'label_value.dart';

class MembershipHero {
  const MembershipHero({
    required this.eyebrow,
    required this.title,
    required this.lead,
    required this.applyButton,
  });

  factory MembershipHero.fromJson(Map<String, dynamic> json) => MembershipHero(
        eyebrow: json['eyebrow'] as String? ?? '',
        title: json['title'] as String? ?? '',
        lead: json['lead'] as String? ?? '',
        applyButton: json['applyButton'] as String? ?? '',
      );

  final String eyebrow;
  final String title;
  final String lead;
  final String applyButton;
}

class MembershipTypeItem {
  const MembershipTypeItem({required this.key, required this.name, required this.body});

  factory MembershipTypeItem.fromJson(Map<String, dynamic> json) => MembershipTypeItem(
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String key;
  final String name;
  final String body;
}

class MembershipTierRow {
  const MembershipTierRow({
    required this.key,
    required this.name,
    required this.eligibility,
    required this.fee,
    required this.rights,
    required this.approval,
  });

  factory MembershipTierRow.fromJson(Map<String, dynamic> json) => MembershipTierRow(
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        eligibility: json['eligibility'] as String? ?? '',
        fee: json['fee'] as String? ?? '',
        rights: json['rights'] as String? ?? '',
        approval: json['approval'] as String? ?? '',
      );

  final String key;
  final String name;
  final String eligibility;
  final String fee;
  final String rights;
  final String approval;
}

class MembershipTiers {
  const MembershipTiers({
    required this.heading,
    required this.subheading,
    required this.feeNote,
    required this.eligibilityLabel,
    required this.feeLabel,
    required this.rightsLabel,
    required this.approvalLabel,
    this.rows = const [],
  });

  factory MembershipTiers.fromJson(Map<String, dynamic> json) {
    final labels = json['labels'] as Map<String, dynamic>? ?? const {};
    final rowsList = json['rows'] as List<dynamic>? ?? [];
    return MembershipTiers(
      heading: json['heading'] as String? ?? '',
      subheading: json['subheading'] as String? ?? '',
      feeNote: json['feeNote'] as String? ?? '',
      eligibilityLabel: labels['eligibility'] as String? ?? '',
      feeLabel: labels['fee'] as String? ?? '',
      rightsLabel: labels['rights'] as String? ?? '',
      approvalLabel: labels['approval'] as String? ?? '',
      rows: rowsList.map((e) => MembershipTierRow.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String heading;
  final String subheading;
  final String feeNote;
  final String eligibilityLabel;
  final String feeLabel;
  final String rightsLabel;
  final String approvalLabel;
  final List<MembershipTierRow> rows;
}

class FaqItem {
  const FaqItem({required this.question, required this.answer});

  factory FaqItem.fromJson(Map<String, dynamic> json) => FaqItem(
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
      );

  final String question;
  final String answer;
}

class HowToApplySection {
  const HowToApplySection({
    required this.heading,
    required this.subheading,
    required this.cta,
    this.steps = const [],
  });

  factory HowToApplySection.fromJson(Map<String, dynamic> json) {
    final stepsList = json['steps'] as List<dynamic>? ?? [];
    return HowToApplySection(
      heading: json['heading'] as String? ?? '',
      subheading: json['subheading'] as String? ?? '',
      cta: json['cta'] as String? ?? '',
      steps: stepsList.map((e) => TitleBody.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String heading;
  final String subheading;
  final String cta;
  final List<TitleBody> steps;
}

class FaqSection {
  const FaqSection({required this.heading, required this.subheading, this.items = const []});

  factory FaqSection.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return FaqSection(
      heading: json['heading'] as String? ?? '',
      subheading: json['subheading'] as String? ?? '',
      items: itemsList.map((e) => FaqItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String heading;
  final String subheading;
  final List<FaqItem> items;
}

class ApplyCta {
  const ApplyCta({required this.heading, required this.body, required this.button});

  factory ApplyCta.fromJson(Map<String, dynamic> json) => ApplyCta(
        heading: json['heading'] as String? ?? '',
        body: json['body'] as String? ?? '',
        button: json['button'] as String? ?? '',
      );

  final String heading;
  final String body;
  final String button;
}

class MembershipContent {
  const MembershipContent({
    required this.hero,
    required this.typesHeading,
    required this.typesSubheading,
    this.types = const [],
    required this.benefitsHeading,
    required this.benefitsSubheading,
    this.benefits = const [],
    required this.tiers,
    required this.rightsHeading,
    required this.rightsSubheading,
    this.rights = const [],
    required this.dutiesHeading,
    required this.dutiesSubheading,
    this.duties = const [],
    required this.terminationHeading,
    required this.terminationSubheading,
    this.termination = const [],
    required this.howToApply,
    required this.faq,
    required this.applyCta,
  });

  factory MembershipContent.fromJson(Map<String, dynamic> json) {
    final typesList = json['types'] as List<dynamic>? ?? [];
    final benefitsList = json['benefits'] as List<dynamic>? ?? [];

    return MembershipContent(
      hero: MembershipHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      typesHeading: json['typesHeading'] as String? ?? '',
      typesSubheading: json['typesSubheading'] as String? ?? '',
      types: typesList.map((e) => MembershipTypeItem.fromJson(e as Map<String, dynamic>)).toList(),
      benefitsHeading: json['benefitsHeading'] as String? ?? '',
      benefitsSubheading: json['benefitsSubheading'] as String? ?? '',
      benefits: benefitsList.map((e) => TitleBody.fromJson(e as Map<String, dynamic>)).toList(),
      tiers: MembershipTiers.fromJson(json['tiers'] as Map<String, dynamic>? ?? const {}),
      rightsHeading: json['rightsHeading'] as String? ?? '',
      rightsSubheading: json['rightsSubheading'] as String? ?? '',
      rights: ((json['rights'] as List<dynamic>?) ?? []).map((e) => e as String).toList(),
      dutiesHeading: json['dutiesHeading'] as String? ?? '',
      dutiesSubheading: json['dutiesSubheading'] as String? ?? '',
      duties: ((json['duties'] as List<dynamic>?) ?? []).map((e) => e as String).toList(),
      terminationHeading: json['terminationHeading'] as String? ?? '',
      terminationSubheading: json['terminationSubheading'] as String? ?? '',
      termination: ((json['termination'] as List<dynamic>?) ?? []).map((e) => e as String).toList(),
      howToApply: HowToApplySection.fromJson(json['howToApply'] as Map<String, dynamic>? ?? const {}),
      faq: FaqSection.fromJson(json['faq'] as Map<String, dynamic>? ?? const {}),
      applyCta: ApplyCta.fromJson(json['applyCta'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final MembershipHero hero;
  final String typesHeading;
  final String typesSubheading;
  final List<MembershipTypeItem> types;
  final String benefitsHeading;
  final String benefitsSubheading;
  final List<TitleBody> benefits;
  final MembershipTiers tiers;
  final String rightsHeading;
  final String rightsSubheading;
  final List<String> rights;
  final String dutiesHeading;
  final String dutiesSubheading;
  final List<String> duties;
  final String terminationHeading;
  final String terminationSubheading;
  final List<String> termination;
  final HowToApplySection howToApply;
  final FaqSection faq;
  final ApplyCta applyCta;
}
