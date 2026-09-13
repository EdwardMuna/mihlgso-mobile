import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/admin_member.dart';
import '../models/contribution_type.dart';
import '../models/donation.dart';
import '../models/member_application.dart';
import '../models/org_stats.dart';
import '../models/payment.dart';

/// Wraps the /api/admin/* endpoints. Every call here requires an ADMIN
/// bearer token — the backend re-checks the role on every request regardless
/// of what this client sends.
class AdminService {
  AdminService(this._client);

  final ApiClient _client;

  Future<List<MemberApplicationSummary>> fetchApplications({String? status}) async {
    final json = await _client.get('/admin/applications', query: status != null ? {'status': status} : null);
    final list = json['applications'] as List<dynamic>? ?? [];
    return list.map((e) => MemberApplicationSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Returns the newly issued temp password on success (shown once to the admin).
  Future<String> approveApplication(int id) async {
    final json = await _client.post('/admin/applications/$id/approve');
    return json['tempPassword'] as String? ?? '';
  }

  Future<void> rejectApplication(int id) async {
    await _client.post('/admin/applications/$id/reject');
  }

  Future<List<AdminMember>> fetchMembers({String? query}) async {
    final json = await _client.get('/admin/members', query: query != null && query.isNotEmpty ? {'q': query} : null);
    final list = json['members'] as List<dynamic>? ?? [];
    // A single malformed row must not drop the rest of the members from the
    // list — parse defensively and skip only the row that actually fails.
    final members = <AdminMember>[];
    for (final e in list) {
      try {
        members.add(AdminMember.fromJson(e as Map<String, dynamic>));
      } catch (_) {
        // Skip this row only; the rest of the list still renders.
      }
    }
    return members;
  }

  Future<AdminMember> fetchMember(int id) async {
    final json = await _client.get('/admin/members/$id');
    return AdminMember.fromJson(json['member'] as Map<String, dynamic>);
  }

  Future<void> setMemberStatus(int id, AdminMember member, String status) async {
    await _client.patch('/admin/members/$id', data: {
      'name': member.name,
      'email': member.email,
      'status': status,
    });
  }

  Future<AdminMember> createMember({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? institution,
    String? academicDiscipline,
    String? graduatedYear,
    String? postalAddress,
    String? currentResidential,
    String? employmentStatus,
    String? educationLevel,
    String? employer,
    String? gender,
    bool isDonor = false,
  }) async {
    final json = await _client.post('/admin/members', data: {
      'name': name,
      'email': email,
      'password': password,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (institution != null && institution.isNotEmpty) 'institution': institution,
      if (academicDiscipline != null && academicDiscipline.isNotEmpty) 'academicDiscipline': academicDiscipline,
      if (graduatedYear != null && graduatedYear.isNotEmpty) 'graduatedYear': graduatedYear,
      if (postalAddress != null && postalAddress.isNotEmpty) 'postalAddress': postalAddress,
      if (currentResidential != null && currentResidential.isNotEmpty) 'currentResidential': currentResidential,
      if (employmentStatus != null && employmentStatus.isNotEmpty) 'employmentStatus': employmentStatus,
      if (educationLevel != null && educationLevel.isNotEmpty) 'educationLevel': educationLevel,
      if (employer != null && employer.isNotEmpty) 'employer': employer,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      'isDonor': isDonor,
    });
    return AdminMember.fromJson(json['member'] as Map<String, dynamic>);
  }

  Future<AdminMember> updateMember(
    int id, {
    required String name,
    required String email,
    required String status,
    String? phone,
    String? institution,
    String? academicDiscipline,
    String? graduatedYear,
    String? postalAddress,
    String? currentResidential,
    String? employmentStatus,
    String? educationLevel,
    String? employer,
    String? gender,
    bool isDonor = false,
    String? newPassword,
  }) async {
    final json = await _client.patch('/admin/members/$id', data: {
      'name': name,
      'email': email,
      'status': status,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
      if (institution != null && institution.isNotEmpty) 'institution': institution,
      if (academicDiscipline != null && academicDiscipline.isNotEmpty) 'academicDiscipline': academicDiscipline,
      if (graduatedYear != null && graduatedYear.isNotEmpty) 'graduatedYear': graduatedYear,
      if (postalAddress != null && postalAddress.isNotEmpty) 'postalAddress': postalAddress,
      if (currentResidential != null && currentResidential.isNotEmpty) 'currentResidential': currentResidential,
      if (employmentStatus != null && employmentStatus.isNotEmpty) 'employmentStatus': employmentStatus,
      if (educationLevel != null && educationLevel.isNotEmpty) 'educationLevel': educationLevel,
      if (employer != null && employer.isNotEmpty) 'employer': employer,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      'isDonor': isDonor,
      if (newPassword != null && newPassword.isNotEmpty) 'newPassword': newPassword,
    });
    return AdminMember.fromJson(json['member'] as Map<String, dynamic>);
  }

  /// multipart POST /api/admin/members/:id/photo — sets/replaces a member's
  /// passport photo from the create/edit member form.
  Future<void> uploadMemberPhoto(int id, String photoPath) async {
    final form = FormData.fromMap({'photo': await MultipartFile.fromFile(photoPath)});
    await _client.postForm('/admin/members/$id/photo', form);
  }

  Future<OrgStats> fetchOrgStats() async {
    final json = await _client.get('/admin/org-stats');
    return OrgStats.fromJson(json);
  }

  Future<OrgStats> updateOrgStats(int beneficiariesCount) async {
    await _client.patch('/admin/org-stats', data: {'beneficiariesCount': beneficiariesCount});
    return fetchOrgStats();
  }

  Future<Payment> approvePayment(int id) async {
    final json = await _client.patch('/admin/payments/$id', data: {'approvalStatus': 'APPROVED'});
    return Payment.fromJson(json['payment'] as Map<String, dynamic>);
  }

  Future<Payment> rejectPayment(int id) async {
    final json = await _client.patch('/admin/payments/$id', data: {'approvalStatus': 'REJECTED'});
    return Payment.fromJson(json['payment'] as Map<String, dynamic>);
  }

  Future<void> deletePayment(int id) async {
    await _client.delete('/admin/payments/$id');
  }

  Future<Donation> approveDonation(int id) async {
    final json = await _client.patch('/admin/donations/$id', data: {'approvalStatus': 'APPROVED'});
    return Donation.fromJson(json['donation'] as Map<String, dynamic>);
  }

  Future<Donation> rejectDonation(int id) async {
    final json = await _client.patch('/admin/donations/$id', data: {'approvalStatus': 'REJECTED'});
    return Donation.fromJson(json['donation'] as Map<String, dynamic>);
  }

  Future<void> deleteDonation(int id) async {
    await _client.delete('/admin/donations/$id');
  }

  Future<List<ContributionType>> fetchContributionTypes() async {
    final json = await _client.get('/admin/contribution-types');
    final list = json['contributionTypes'] as List<dynamic>? ?? [];
    return list.map((e) => ContributionType.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ContributionType> createContributionType({
    required String name,
    required double amount,
    String? description,
    bool isActive = true,
  }) async {
    final json = await _client.post('/admin/contribution-types', data: {
      'name': name,
      'amount': amount,
      'description': description,
      'isActive': isActive,
    });
    return ContributionType.fromJson(json['contributionType'] as Map<String, dynamic>);
  }

  Future<ContributionType> updateContributionType(
    int id, {
    required String name,
    required double amount,
    String? description,
    required bool isActive,
  }) async {
    final json = await _client.patch('/admin/contribution-types/$id', data: {
      'name': name,
      'amount': amount,
      'description': description,
      'isActive': isActive,
    });
    return ContributionType.fromJson(json['contributionType'] as Map<String, dynamic>);
  }

  Future<void> deleteContributionType(int id) async {
    await _client.delete('/admin/contribution-types/$id');
  }

  /// Records a donation on behalf of a donor. Mirrors [MemberService.recordDonation]
  /// (same POST /api/donations endpoint) — kept here too so the admin donations
  /// screen can create records without depending on MemberService directly.
  Future<void> createDonation({
    required String donorName,
    required double amount,
    required DateTime donatedAt,
    String? donorEmail,
    String? donorPhone,
    String? purpose,
    String? reference,
    String? notes,
  }) async {
    await _client.post('/donations', data: {
      'donorName': donorName,
      'amount': amount,
      'donatedAt': donatedAt.toIso8601String(),
      if (donorEmail != null && donorEmail.isNotEmpty) 'donorEmail': donorEmail,
      if (donorPhone != null && donorPhone.isNotEmpty) 'donorPhone': donorPhone,
      if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
      if (reference != null && reference.isNotEmpty) 'reference': reference,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }
}
