class ContactPhone {
  const ContactPhone({required this.display, required this.e164});

  factory ContactPhone.fromJson(Map<String, dynamic> json) => ContactPhone(
        display: json['display'] as String? ?? '',
        e164: json['e164'] as String? ?? '',
      );

  final String display;
  final String e164;
}

class ContactInfo {
  const ContactInfo({
    required this.heroEyebrow,
    required this.heroTitle,
    required this.heroLead,
    required this.addressHeading,
    required this.address,
    required this.phoneHeading,
    required this.phones,
    required this.phoneNote,
    required this.whatsappHeading,
    required this.whatsappNote,
    required this.mapHeading,
    required this.mapEmbedUrl,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    final hero = json['hero'] as Map<String, dynamic>? ?? const {};
    final info = json['info'] as Map<String, dynamic>? ?? const {};
    final map = json['map'] as Map<String, dynamic>? ?? const {};
    final phonesList = info['phones'] as List<dynamic>? ?? [];

    return ContactInfo(
      heroEyebrow: hero['eyebrow'] as String? ?? '',
      heroTitle: hero['title'] as String? ?? '',
      heroLead: hero['lead'] as String? ?? '',
      addressHeading: info['addressHeading'] as String? ?? '',
      address: info['address'] as String? ?? '',
      phoneHeading: info['phoneHeading'] as String? ?? '',
      phones: phonesList.map((e) => ContactPhone.fromJson(e as Map<String, dynamic>)).toList(),
      phoneNote: info['phoneNote'] as String? ?? '',
      whatsappHeading: info['whatsappHeading'] as String? ?? '',
      whatsappNote: info['whatsappNote'] as String? ?? '',
      mapHeading: map['heading'] as String? ?? '',
      mapEmbedUrl: map['embedUrl'] as String? ?? '',
    );
  }

  final String heroEyebrow;
  final String heroTitle;
  final String heroLead;
  final String addressHeading;
  final String address;
  final String phoneHeading;
  final List<ContactPhone> phones;
  final String phoneNote;
  final String whatsappHeading;
  final String whatsappNote;
  final String mapHeading;
  final String mapEmbedUrl;
}
