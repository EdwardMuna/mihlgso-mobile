import 'about_sections.dart';
import 'label_value.dart';
import 'leadership_member.dart';

/// Shared shape for Board and Executive — hero, filtered members, an
/// optional composition note, and a "duties" section (the site itself calls
/// this "mandate" for Board and "duties.offices" for Executive; normalized
/// to one shape here since the backend already unifies them).
class LeadershipGroupContent {
  const LeadershipGroupContent({
    required this.hero,
    this.members = const [],
    this.compositionNote,
    required this.dutiesEyebrow,
    required this.dutiesTitle,
    required this.dutiesLead,
    this.duties = const [],
  });

  factory LeadershipGroupContent.fromJson(Map<String, dynamic> json) {
    final membersList = json['members'] as List<dynamic>? ?? [];
    final duties = json['duties'] as Map<String, dynamic>? ?? const {};
    final dutyItems = duties['items'] as List<dynamic>? ?? [];
    return LeadershipGroupContent(
      hero: SectionHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      members: membersList.map((e) => LeadershipMember.fromJson(e as Map<String, dynamic>)).toList(),
      compositionNote: json['compositionNote'] as String?,
      dutiesEyebrow: duties['eyebrow'] as String? ?? '',
      dutiesTitle: duties['title'] as String? ?? '',
      dutiesLead: duties['lead'] as String? ?? '',
      duties: dutyItems.map((e) => TitleBody.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final SectionHero hero;
  final List<LeadershipMember> members;
  final String? compositionNote;
  final String dutiesEyebrow;
  final String dutiesTitle;
  final String dutiesLead;
  final List<TitleBody> duties;
}

class DepartmentItem {
  const DepartmentItem({required this.key, required this.name, required this.body});

  factory DepartmentItem.fromJson(Map<String, dynamic> json) => DepartmentItem(
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String key;
  final String name;
  final String body;
}

class DepartmentDetail {
  const DepartmentDetail({
    required this.key,
    required this.name,
    required this.focusLabel,
    this.focus = const [],
  });

  factory DepartmentDetail.fromJson(Map<String, dynamic> json) {
    final focusList = json['focus'] as List<dynamic>? ?? [];
    return DepartmentDetail(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      focusLabel: json['focusLabel'] as String? ?? '',
      focus: focusList.map((e) => e as String).toList(),
    );
  }

  final String key;
  final String name;
  final String focusLabel;
  final List<String> focus;
}

class DepartmentsContent {
  const DepartmentsContent({
    required this.hero,
    this.departments = const [],
    required this.detailEyebrow,
    required this.detailTitle,
    required this.detailLead,
    this.details = const [],
    required this.governanceEyebrow,
    required this.governanceTitle,
    required this.governanceBody,
  });

  factory DepartmentsContent.fromJson(Map<String, dynamic> json) {
    final departmentsList = json['departments'] as List<dynamic>? ?? [];
    final detail = json['detail'] as Map<String, dynamic>? ?? const {};
    final detailItems = detail['items'] as List<dynamic>? ?? [];
    final governance = json['governance'] as Map<String, dynamic>? ?? const {};
    return DepartmentsContent(
      hero: SectionHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      departments: departmentsList.map((e) => DepartmentItem.fromJson(e as Map<String, dynamic>)).toList(),
      detailEyebrow: detail['eyebrow'] as String? ?? '',
      detailTitle: detail['title'] as String? ?? '',
      detailLead: detail['lead'] as String? ?? '',
      details: detailItems.map((e) => DepartmentDetail.fromJson(e as Map<String, dynamic>)).toList(),
      governanceEyebrow: governance['eyebrow'] as String? ?? '',
      governanceTitle: governance['title'] as String? ?? '',
      governanceBody: governance['body'] as String? ?? '',
    );
  }

  final SectionHero hero;
  final List<DepartmentItem> departments;
  final String detailEyebrow;
  final String detailTitle;
  final String detailLead;
  final List<DepartmentDetail> details;
  final String governanceEyebrow;
  final String governanceTitle;
  final String governanceBody;
}

class LeadershipGroupLink {
  const LeadershipGroupLink({
    required this.key,
    required this.name,
    required this.intro,
    required this.viewLink,
  });

  factory LeadershipGroupLink.fromJson(Map<String, dynamic> json) => LeadershipGroupLink(
        key: json['key'] as String? ?? '',
        name: json['name'] as String? ?? '',
        intro: json['intro'] as String? ?? '',
        viewLink: json['viewLink'] as String? ?? '',
      );

  final String key;
  final String name;
  final String intro;
  final String viewLink;
}

class StructureLayer {
  const StructureLayer({required this.role, required this.name, required this.body});

  factory StructureLayer.fromJson(Map<String, dynamic> json) => StructureLayer(
        role: json['role'] as String? ?? '',
        name: json['name'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String role;
  final String name;
  final String body;
}

class LeadershipOverviewContent {
  const LeadershipOverviewContent({
    this.leaders = const [],
    this.openRoles = const [],
    required this.hero,
    this.groups = const [],
    required this.structureEyebrow,
    required this.structureTitle,
    required this.structureLead,
    this.structureLayers = const [],
    required this.agmTitle,
    required this.agmBody,
    required this.principlesEyebrow,
    required this.principlesTitle,
    required this.principlesLead,
    this.principles = const [],
    required this.joinCtaEyebrow,
    required this.joinCtaTitle,
    required this.joinCtaBody,
    required this.joinCtaPrimary,
    required this.joinCtaSecondary,
  });

  factory LeadershipOverviewContent.fromJson(Map<String, dynamic> json) {
    final leadersList = json['data'] as List<dynamic>? ?? [];
    final openRolesList = json['openRoles'] as List<dynamic>? ?? [];
    final groupsList = json['groups'] as List<dynamic>? ?? [];
    final structure = json['structure'] as Map<String, dynamic>? ?? const {};
    final layersList = structure['layers'] as List<dynamic>? ?? [];
    final principles = json['principles'] as Map<String, dynamic>? ?? const {};
    final principlesList = principles['items'] as List<dynamic>? ?? [];
    final joinCta = json['joinCta'] as Map<String, dynamic>? ?? const {};

    return LeadershipOverviewContent(
      leaders: leadersList.map((e) => LeadershipMember.fromJson(e as Map<String, dynamic>)).toList(),
      openRoles: openRolesList.map((e) => LeadershipOpenRole.fromJson(e as Map<String, dynamic>)).toList(),
      hero: SectionHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      groups: groupsList.map((e) => LeadershipGroupLink.fromJson(e as Map<String, dynamic>)).toList(),
      structureEyebrow: structure['eyebrow'] as String? ?? '',
      structureTitle: structure['title'] as String? ?? '',
      structureLead: structure['lead'] as String? ?? '',
      structureLayers: layersList.map((e) => StructureLayer.fromJson(e as Map<String, dynamic>)).toList(),
      agmTitle: structure['agmTitle'] as String? ?? '',
      agmBody: structure['agmBody'] as String? ?? '',
      principlesEyebrow: principles['eyebrow'] as String? ?? '',
      principlesTitle: principles['title'] as String? ?? '',
      principlesLead: principles['lead'] as String? ?? '',
      principles: principlesList.map((e) => TitleBody.fromJson(e as Map<String, dynamic>)).toList(),
      joinCtaEyebrow: joinCta['eyebrow'] as String? ?? '',
      joinCtaTitle: joinCta['title'] as String? ?? '',
      joinCtaBody: joinCta['body'] as String? ?? '',
      joinCtaPrimary: joinCta['primary'] as String? ?? '',
      joinCtaSecondary: joinCta['secondary'] as String? ?? '',
    );
  }

  final List<LeadershipMember> leaders;
  final List<LeadershipOpenRole> openRoles;
  final SectionHero hero;
  final List<LeadershipGroupLink> groups;
  final String structureEyebrow;
  final String structureTitle;
  final String structureLead;
  final List<StructureLayer> structureLayers;
  final String agmTitle;
  final String agmBody;
  final String principlesEyebrow;
  final String principlesTitle;
  final String principlesLead;
  final List<TitleBody> principles;
  final String joinCtaEyebrow;
  final String joinCtaTitle;
  final String joinCtaBody;
  final String joinCtaPrimary;
  final String joinCtaSecondary;
}
