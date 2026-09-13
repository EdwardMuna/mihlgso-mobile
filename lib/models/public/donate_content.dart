import 'contact_info.dart';

class DonateHero {
  const DonateHero({
    required this.eyebrow,
    required this.title,
    required this.lead,
    this.image,
    required this.imageAlt,
  });

  factory DonateHero.fromJson(Map<String, dynamic> json) => DonateHero(
        eyebrow: json['eyebrow'] as String? ?? '',
        title: json['title'] as String? ?? '',
        lead: json['lead'] as String? ?? '',
        image: json['image'] as String?,
        imageAlt: json['imageAlt'] as String? ?? '',
      );

  final String eyebrow;
  final String title;
  final String lead;
  final String? image;
  final String imageAlt;
}

class ImpactItem {
  const ImpactItem({required this.icon, required this.title, required this.body});

  factory ImpactItem.fromJson(Map<String, dynamic> json) => ImpactItem(
        icon: json['icon'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String icon;
  final String title;
  final String body;
}

class DonateWhatsapp {
  const DonateWhatsapp({required this.title, required this.body, required this.button, required this.url});

  factory DonateWhatsapp.fromJson(Map<String, dynamic> json) => DonateWhatsapp(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        button: json['button'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  final String title;
  final String body;
  final String button;
  final String url;
}

class DonatePhoneWay {
  const DonatePhoneWay({
    required this.title,
    required this.body,
    required this.note,
    this.phones = const [],
  });

  factory DonatePhoneWay.fromJson(Map<String, dynamic> json) {
    final phonesList = json['phones'] as List<dynamic>? ?? [];
    return DonatePhoneWay(
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      note: json['note'] as String? ?? '',
      phones: phonesList.map((e) => ContactPhone.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  final String title;
  final String body;
  final String note;
  final List<ContactPhone> phones;
}

class DonateBankWay {
  const DonateBankWay({required this.title, required this.body, required this.button, required this.url});

  factory DonateBankWay.fromJson(Map<String, dynamic> json) => DonateBankWay(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        button: json['button'] as String? ?? '',
        url: json['url'] as String? ?? '',
      );

  final String title;
  final String body;
  final String button;
  final String url;
}

class DonateTrust {
  const DonateTrust({required this.heading, required this.body});

  factory DonateTrust.fromJson(Map<String, dynamic> json) => DonateTrust(
        heading: json['heading'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  final String heading;
  final String body;
}

class DonateContent {
  const DonateContent({
    required this.hero,
    required this.impactHeading,
    required this.impactSubheading,
    this.impact = const [],
    required this.waysHeading,
    required this.waysSubheading,
    required this.whatsapp,
    required this.phone,
    required this.bank,
    required this.trust,
  });

  factory DonateContent.fromJson(Map<String, dynamic> json) {
    final impact = json['impact'] as Map<String, dynamic>? ?? const {};
    final impactItems = impact['items'] as List<dynamic>? ?? [];
    final ways = json['ways'] as Map<String, dynamic>? ?? const {};

    return DonateContent(
      hero: DonateHero.fromJson(json['hero'] as Map<String, dynamic>? ?? const {}),
      impactHeading: impact['heading'] as String? ?? '',
      impactSubheading: impact['subheading'] as String? ?? '',
      impact: impactItems.map((e) => ImpactItem.fromJson(e as Map<String, dynamic>)).toList(),
      waysHeading: ways['heading'] as String? ?? '',
      waysSubheading: ways['subheading'] as String? ?? '',
      whatsapp: DonateWhatsapp.fromJson(ways['whatsapp'] as Map<String, dynamic>? ?? const {}),
      phone: DonatePhoneWay.fromJson(ways['phone'] as Map<String, dynamic>? ?? const {}),
      bank: DonateBankWay.fromJson(ways['bank'] as Map<String, dynamic>? ?? const {}),
      trust: DonateTrust.fromJson(json['trust'] as Map<String, dynamic>? ?? const {}),
    );
  }

  final DonateHero hero;
  final String impactHeading;
  final String impactSubheading;
  final List<ImpactItem> impact;
  final String waysHeading;
  final String waysSubheading;
  final DonateWhatsapp whatsapp;
  final DonatePhoneWay phone;
  final DonateBankWay bank;
  final DonateTrust trust;
}
