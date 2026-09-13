class AdminMember {
  const AdminMember({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    this.phone,
    this.institution,
    this.educationLevel,
    this.graduatedYear,
    this.academicDiscipline,
    this.employer,
    this.gender,
    this.isDonor = false,
    this.createdAt,
    this.postalAddress,
    this.currentResidential,
    this.employmentStatus,
    this.photoDataUrl,
    this.role,
  });

  /// Defensive parsing: a single malformed/unexpected row (e.g. a legacy
  /// record with an unexpected type) must not throw and take down the
  /// entire members list — every field beyond id/name/email falls back to
  /// a safe default instead of a hard cast.
  factory AdminMember.fromJson(Map<String, dynamic> json) {
    return AdminMember(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      institution: json['institution'] as String?,
      educationLevel: json['educationLevel'] as String?,
      graduatedYear: (json['graduatedYear'] as num?)?.toInt(),
      academicDiscipline: json['academicDiscipline'] as String?,
      employer: json['employer'] as String?,
      gender: json['gender'] as String?,
      isDonor: json['isDonor'] as bool? ?? false,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      postalAddress: json['postalAddress'] as String?,
      currentResidential: json['currentResidential'] as String?,
      employmentStatus: json['employmentStatus'] as String?,
      photoDataUrl: json['photoDataUrl'] as String?,
      role: json['role'] as String?,
    );
  }

  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? institution;
  final String? educationLevel;
  final int? graduatedYear;
  final String? academicDiscipline;
  final String? employer;
  final String? gender;
  final bool isDonor;
  final String status;
  final DateTime? createdAt;
  final String? postalAddress;
  final String? currentResidential;
  final String? employmentStatus;

  /// A `data:<mime>;base64,<...>` URL, or null when the member has no photo.
  final String? photoDataUrl;

  /// 'ADMIN' | 'MEMBER'.
  final String? role;
}
