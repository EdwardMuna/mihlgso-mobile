enum ApplicationStatus { pending, approved, rejected }

ApplicationStatus applicationStatusFromJson(String value) {
  switch (value) {
    case 'APPROVED':
      return ApplicationStatus.approved;
    case 'REJECTED':
      return ApplicationStatus.rejected;
    default:
      return ApplicationStatus.pending;
  }
}

class MemberApplicationSummary {
  const MemberApplicationSummary({
    required this.id,
    required this.registrationType,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdAt,
    this.institution,
    this.levelOfEducation,
    this.graduatedYear,
    this.postalAddress,
    this.currentResidential,
    this.employmentStatus,
    this.gender,
    this.academicDiscipline,
    this.employer,
    this.nationality,
    this.placeOfLiving,
    this.message,
    this.reviewedAt,
    this.memberType,
    this.photoDataUrl,
  });

  factory MemberApplicationSummary.fromJson(Map<String, dynamic> json) {
    return MemberApplicationSummary(
      id: json['id'] as int,
      registrationType: json['registrationType'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      institution: json['institution'] as String?,
      levelOfEducation: json['levelOfEducation'] as String?,
      graduatedYear: (json['graduatedYear'] as num?)?.toInt(),
      postalAddress: json['postalAddress'] as String?,
      currentResidential: json['currentResidential'] as String?,
      employmentStatus: json['employmentStatus'] as String?,
      gender: json['gender'] as String?,
      academicDiscipline: json['academicDiscipline'] as String?,
      employer: json['employer'] as String?,
      nationality: json['nationality'] as String?,
      placeOfLiving: json['placeOfLiving'] as String?,
      message: json['message'] as String?,
      status: applicationStatusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      reviewedAt: json['reviewedAt'] != null ? DateTime.tryParse(json['reviewedAt'] as String) : null,
      memberType: json['memberType'] as String?,
      photoDataUrl: json['photoDataUrl'] as String?,
    );
  }

  final int id;
  final String registrationType;
  final String name;
  final String email;
  final String phone;
  final String? institution;
  final String? levelOfEducation;
  final int? graduatedYear;
  final String? postalAddress;
  final String? currentResidential;
  final String? employmentStatus;
  final String? gender;
  final String? academicDiscipline;
  final String? employer;
  final String? nationality;
  final String? placeOfLiving;
  final String? message;
  final ApplicationStatus status;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  /// 'ORDINARY' | 'GRADUATE' | 'HONORABLE', assigned at approval — null
  /// until then.
  final String? memberType;

  /// A `data:<mime>;base64,<...>` URL of the applicant's submitted photo,
  /// or null if none was attached.
  final String? photoDataUrl;
}
