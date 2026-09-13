import 'gallery_album.dart';

class HeroStat {
  const HeroStat({required this.value, required this.label});

  factory HeroStat.fromJson(Map<String, dynamic> json) => HeroStat(
        value: json['value'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );

  final String value;
  final String label;
}

class HeroContent {
  const HeroContent({
    required this.trust,
    required this.title,
    required this.tagline,
    this.image,
    required this.members,
    required this.projects,
    required this.since,
  });

  factory HeroContent.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? const {};
    return HeroContent(
      trust: json['trust'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      image: json['image'] as String?,
      members: HeroStat.fromJson(stats['members'] as Map<String, dynamic>? ?? const {}),
      projects: HeroStat.fromJson(stats['projects'] as Map<String, dynamic>? ?? const {}),
      since: HeroStat.fromJson(stats['since'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final String trust;
  final String title;
  final String tagline;
  final String? image;
  final HeroStat members;
  final HeroStat projects;
  final HeroStat since;
}

class StoryContent {
  const StoryContent({
    required this.eyebrow,
    required this.heading,
    required this.body,
    this.image,
    this.principles = const [],
  });

  factory StoryContent.fromJson(Map<String, dynamic> json) {
    final principlesList = json['principles'] as List<dynamic>? ?? [];
    return StoryContent(
      eyebrow: json['eyebrow'] as String? ?? '',
      heading: json['heading'] as String? ?? '',
      body: json['body'] as String? ?? '',
      image: json['image'] as String?,
      principles: principlesList.map((e) => e as String).toList(),
    );
  }

  final String eyebrow;
  final String heading;
  final String body;
  final String? image;
  final List<String> principles;
}

class PillarItem {
  const PillarItem({required this.icon, required this.title, required this.body});

  factory PillarItem.fromJson(Map<String, dynamic> json) => PillarItem(
        icon: json['icon'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String icon;
  final String title;
  final String body;
}

class HomeProjectTeaser {
  const HomeProjectTeaser({
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.summary,
    this.image,
  });

  factory HomeProjectTeaser.fromJson(Map<String, dynamic> json) => HomeProjectTeaser(
        slug: json['slug'] as String? ?? '',
        title: json['title'] as String? ?? '',
        subtitle: json['subtitle'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        image: json['image'] as String?,
      );

  final String slug;
  final String title;
  final String subtitle;
  final String summary;
  final String? image;
}

class HighlightsSection {
  const HighlightsSection({
    required this.eyebrow,
    required this.heading,
    required this.body,
    this.images = const [],
  });

  factory HighlightsSection.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>? ?? [];
    return HighlightsSection(
      eyebrow: json['eyebrow'] as String? ?? '',
      heading: json['heading'] as String? ?? '',
      body: json['body'] as String? ?? '',
      images: imagesList
          .map((e) => GalleryImage.fromJson({'id': '', ...e as Map<String, dynamic>}))
          .toList(),
    );
  }

  final String eyebrow;
  final String heading;
  final String body;
  final List<GalleryImage> images;
}

class GetInvolvedItem {
  const GetInvolvedItem({required this.icon, required this.title, required this.body});

  factory GetInvolvedItem.fromJson(Map<String, dynamic> json) => GetInvolvedItem(
        icon: json['icon'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String icon;
  final String title;
  final String body;
}

class JourneyMilestone {
  const JourneyMilestone({required this.year, required this.title, required this.body});

  factory JourneyMilestone.fromJson(Map<String, dynamic> json) => JourneyMilestone(
        year: json['year'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String year;
  final String title;
  final String body;
}

class DonateCta {
  const DonateCta({required this.heading, required this.body});

  factory DonateCta.fromJson(Map<String, dynamic> json) => DonateCta(
        heading: json['heading'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String heading;
  final String body;
}

class HomeContent {
  const HomeContent({
    required this.hero,
    required this.story,
    required this.pillarsHeading,
    required this.pillarsSubheading,
    required this.pillars,
    required this.currentProjectsHeading,
    required this.currentProjects,
    required this.highlights,
    required this.getInvolvedEyebrow,
    required this.getInvolvedHeading,
    required this.getInvolvedSubheading,
    required this.getInvolved,
    required this.journeyEyebrow,
    required this.journeyHeading,
    required this.journeyMilestones,
    required this.donateCta,
  });

  factory HomeContent.fromJson(Map<String, dynamic> json) {
    final pillars = json['pillars'] as Map<String, dynamic>? ?? const {};
    final currentProjects = json['currentProjects'] as Map<String, dynamic>? ?? const {};
    final getInvolved = json['getInvolved'] as Map<String, dynamic>? ?? const {};
    final journey = json['journey'] as Map<String, dynamic>? ?? const {};

    return HomeContent(
      hero: HeroContent.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      story: StoryContent.fromJson(json['story'] as Map<String, dynamic>? ?? const {}),
      pillarsHeading: pillars['heading'] as String? ?? '',
      pillarsSubheading: pillars['subheading'] as String? ?? '',
      pillars: ((pillars['items'] as List<dynamic>?) ?? [])
          .map((e) => PillarItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentProjectsHeading: currentProjects['heading'] as String? ?? '',
      currentProjects: ((currentProjects['items'] as List<dynamic>?) ?? [])
          .map((e) => HomeProjectTeaser.fromJson(e as Map<String, dynamic>))
          .toList(),
      highlights: HighlightsSection.fromJson(json['highlights'] as Map<String, dynamic>? ?? const {}),
      getInvolvedEyebrow: getInvolved['eyebrow'] as String? ?? '',
      getInvolvedHeading: getInvolved['heading'] as String? ?? '',
      getInvolvedSubheading: getInvolved['subheading'] as String? ?? '',
      getInvolved: ((getInvolved['items'] as List<dynamic>?) ?? [])
          .map((e) => GetInvolvedItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      journeyEyebrow: journey['eyebrow'] as String? ?? '',
      journeyHeading: journey['heading'] as String? ?? '',
      journeyMilestones: ((journey['milestones'] as List<dynamic>?) ?? [])
          .map((e) => JourneyMilestone.fromJson(e as Map<String, dynamic>))
          .toList(),
      donateCta: DonateCta.fromJson(json['donateCta'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final HeroContent hero;
  final StoryContent story;
  final String pillarsHeading;
  final String pillarsSubheading;
  final List<PillarItem> pillars;
  final String currentProjectsHeading;
  final List<HomeProjectTeaser> currentProjects;
  final HighlightsSection highlights;
  final String getInvolvedEyebrow;
  final String getInvolvedHeading;
  final String getInvolvedSubheading;
  final List<GetInvolvedItem> getInvolved;
  final String journeyEyebrow;
  final String journeyHeading;
  final List<JourneyMilestone> journeyMilestones;
  final DonateCta donateCta;
}
