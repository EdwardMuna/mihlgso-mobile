/// Mirrors the shape returned by /api/me and /api/auth/login on the backend
/// (see lib/api/auth.ts:getApiUser select clause in the Next.js project).
enum UserRole { admin, member }

UserRole userRoleFromJson(String value) =>
    value == 'ADMIN' ? UserRole.admin : UserRole.member;

enum UserStatus { active, suspended }

UserStatus userStatusFromJson(String value) =>
    value == 'SUSPENDED' ? UserStatus.suspended : UserStatus.active;

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.isDonor,
    this.phone,
    this.institution,
    this.educationLevel,
    this.createdAt,
    this.academicDiscipline,
    this.graduatedYear,
    this.postalAddress,
    this.currentResidential,
    this.employmentStatus,
    this.employer,
    this.gender,
    this.photoDataUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      institution: json['institution'] as String?,
      educationLevel: json['educationLevel'] as String?,
      role: userRoleFromJson(json['role'] as String),
      status: userStatusFromJson(json['status'] as String),
      isDonor: json['isDonor'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      academicDiscipline: json['academicDiscipline'] as String?,
      graduatedYear: (json['graduatedYear'] as num?)?.toInt(),
      postalAddress: json['postalAddress'] as String?,
      currentResidential: json['currentResidential'] as String?,
      employmentStatus: json['employmentStatus'] as String?,
      employer: json['employer'] as String?,
      gender: json['gender'] as String?,
      photoDataUrl: json['photoDataUrl'] as String?,
    );
  }

  final int id;
  final String email;
  final String name;
  final String? phone;
  final String? institution;
  final String? educationLevel;
  final UserRole role;
  final UserStatus status;
  final bool isDonor;
  final DateTime? createdAt;
  final String? academicDiscipline;
  final int? graduatedYear;
  final String? postalAddress;
  final String? currentResidential;
  final String? employmentStatus;
  final String? employer;
  final String? gender;

  /// A `data:<mime>;base64,<...>` URL, or null when the member has no photo.
  final String? photoDataUrl;
}
