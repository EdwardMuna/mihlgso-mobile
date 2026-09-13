import 'label_value.dart';

class ProjectPhase {
  const ProjectPhase({
    required this.title,
    required this.description,
    required this.status,
    required this.statusLabel,
  });

  factory ProjectPhase.fromJson(Map<String, dynamic> json) {
    return ProjectPhase(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ?? '',
    );
  }

  final String title;
  final String description;
  final String status;
  final String statusLabel;
}

class ProjectImage {
  const ProjectImage({required this.src, required this.alt});

  factory ProjectImage.fromJson(Map<String, dynamic> json) {
    return ProjectImage(
      src: json['src'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
    );
  }

  final String src;
  final String alt;
}

class ProjectDonationItem {
  const ProjectDonationItem({
    required this.title,
    required this.amount,
    required this.description,
  });

  factory ProjectDonationItem.fromJson(Map<String, dynamic> json) {
    return ProjectDonationItem(
      title: json['title'] as String? ?? '',
      amount: json['amount'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }

  final String title;
  final String amount;
  final String description;
}

class ProjectDonationInfo {
  const ProjectDonationInfo({required this.lead, required this.items});

  factory ProjectDonationInfo.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return ProjectDonationInfo(
      lead: json['lead'] as String? ?? '',
      items: itemsList.map((e) => ProjectDonationItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String lead;
  final List<ProjectDonationItem> items;
}

class Project {
  const Project({
    required this.slug,
    required this.status,
    required this.statusLabel,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.intro,
    required this.intro2,
    required this.beneficiaries,
    required this.ctaBody,
    this.coverImage,
    this.coverAlt,
    this.gallery = const [],
    this.glance = const [],
    this.phases = const [],
    required this.donation,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    final galleryList = json['gallery'] as List<dynamic>? ?? [];
    final glanceList = json['glance'] as List<dynamic>? ?? [];
    final phasesList = json['phases'] as List<dynamic>? ?? [];
    return Project(
      slug: json['slug'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusLabel: json['statusLabel'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      intro: json['intro'] as String? ?? '',
      intro2: json['intro2'] as String? ?? '',
      beneficiaries: json['beneficiaries'] as String? ?? '',
      ctaBody: json['ctaBody'] as String? ?? '',
      coverImage: json['coverImage'] as String?,
      coverAlt: json['coverAlt'] as String?,
      gallery: galleryList.map((e) => ProjectImage.fromJson(e as Map<String, dynamic>)).toList(),
      glance: glanceList.map((e) => LabelValue.fromJson(e as Map<String, dynamic>)).toList(),
      phases: phasesList.map((e) => ProjectPhase.fromJson(e as Map<String, dynamic>)).toList(),
      donation: ProjectDonationInfo.fromJson(json['donation'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final String slug;
  final String status;
  final String statusLabel;
  final String title;
  final String subtitle;
  final String summary;
  final String intro;
  final String intro2;
  final String beneficiaries;
  final String ctaBody;
  final String? coverImage;
  final String? coverAlt;
  final List<ProjectImage> gallery;
  final List<LabelValue> glance;
  final List<ProjectPhase> phases;
  final ProjectDonationInfo donation;
}
