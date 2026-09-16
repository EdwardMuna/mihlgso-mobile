import 'package:dio/dio.dart';

import '../core/network/api_client.dart';
import '../models/annual_subscription.dart';
import '../models/contribution_type.dart';
import '../models/donation.dart';
import '../models/leaderboard.dart';
import '../models/payment.dart';
import '../models/user.dart';

/// Wraps the signed-in-user endpoints shared by members and admins:
/// GET /api/payments, /api/donations (self-scoped by the backend for
/// non-admins), POST to record a new one, and the public contribution types.
class MemberService {
  MemberService(this._client);

  final ApiClient _client;

  /// PATCH /api/me — mirrors lib/actions/profile.ts:updateProfileAction.
  Future<AppUser> updateProfile({
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
    final json = await _client.patch('/me', data: {
      'phone': phone ?? '',
      'institution': institution ?? '',
      'academicDiscipline': academicDiscipline ?? '',
      'graduatedYear': graduatedYear ?? '',
      'postalAddress': postalAddress ?? '',
      'currentResidential': currentResidential ?? '',
      'employmentStatus': employmentStatus ?? '',
      'educationLevel': educationLevel ?? '',
      'employer': employer ?? '',
      'gender': gender ?? '',
      'isDonor': isDonor,
    });
    return AppUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  /// multipart POST /api/me/photo (2MB/image-type rules enforced server-side).
  Future<void> uploadPhoto(String photoPath) async {
    final form = FormData.fromMap({'photo': await MultipartFile.fromFile(photoPath)});
    await _client.postForm('/me/photo', form);
  }

  /// PATCH /api/me/password — mirrors lib/actions/profile.ts:changePasswordAction.
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    await _client.patch('/me/password', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  /// GET /api/me/annual-subscription — null if no "annual subscription"
  /// contribution type exists on the backend yet.
  Future<AnnualSubscription?> fetchAnnualSubscription() async {
    final json = await _client.get('/me/annual-subscription');
    final data = json['annualSubscription'] as Map<String, dynamic>?;
    return data == null ? null : AnnualSubscription.fromJson(data);
  }

  /// GET /api/leaderboards/contributors — same data as the website's
  /// "Top Contributors" table, or the full "All Contributors" list when
  /// [all] is true.
  Future<LeaderboardResult> fetchTopContributors({int limit = 10, bool all = false}) async {
    final json = await _client.get('/leaderboards/contributors', query: all ? {'all': 1} : {'limit': limit});
    return LeaderboardResult.fromJson(json);
  }

  /// GET /api/leaderboards/donors — same data as the website's "Top Donors"
  /// table, or the full "All Donors" list when [all] is true. [generalLabel]
  /// is the fallback project name shown for donations with no purpose set.
  Future<LeaderboardResult> fetchTopDonors({int limit = 10, bool all = false, required String generalLabel}) async {
    final json = await _client.get('/leaderboards/donors', query: {
      if (all) 'all': 1 else 'limit': limit,
      'generalLabel': generalLabel,
    });
    return LeaderboardResult.fromJson(json);
  }

  Future<List<ContributionType>> fetchContributionTypes() async {
    final json = await _client.get('/contribution-types');
    final list = json['contributionTypes'] as List<dynamic>? ?? [];
    return list
        .map((e) => ContributionType.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Payment>> fetchMyPayments() async {
    final json = await _client.get('/payments');
    final list = json['payments'] as List<dynamic>? ?? [];
    return list.map((e) => Payment.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Donation>> fetchMyDonations() async {
    final json = await _client.get('/donations');
    final list = json['donations'] as List<dynamic>? ?? [];
    return list.map((e) => Donation.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> recordPayment({
    required int contributionTypeId,
    required String paymentName,
    required double amountDue,
    required double amountPaid,
    required DateTime paymentDate,
    String? reference,
    String? notes,
  }) async {
    await _client.post('/payments', data: {
      'contributionTypeId': contributionTypeId,
      'paymentName': paymentName,
      'amountDue': amountDue,
      'amountPaid': amountPaid,
      'paymentDate': paymentDate.toIso8601String(),
      'reference': ?reference,
      'notes': ?notes,
    });
  }

  Future<void> recordDonation({
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
      'donorEmail': ?donorEmail,
      'donorPhone': ?donorPhone,
      'purpose': ?purpose,
      'reference': ?reference,
      'notes': ?notes,
    });
  }

  /// PATCH /api/donations/:id — only the owning member can edit their own
  /// donation, and only while it is still PENDING review (the backend
  /// rejects the request with 409 once an admin has approved/rejected it).
  Future<Donation> updateDonation(
    int id, {
    required String donorName,
    required double amount,
    required DateTime donatedAt,
    String? donorEmail,
    String? donorPhone,
    String? purpose,
    String? reference,
    String? notes,
  }) async {
    final json = await _client.patch('/donations/$id', data: {
      'donorName': donorName,
      'amount': amount,
      'donatedAt': donatedAt.toIso8601String(),
      'donorEmail': ?donorEmail,
      'donorPhone': ?donorPhone,
      'purpose': ?purpose,
      'reference': ?reference,
      'notes': ?notes,
    });
    return Donation.fromJson(json['donation'] as Map<String, dynamic>);
  }
}
