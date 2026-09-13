import 'package:dio/dio.dart';

import '../core/network/api_client.dart';

/// Public membership application submission — mirrors
/// lib/actions/applications.ts:submitApplicationAction via POST /api/applications.
class ApplicationService {
  ApplicationService(this._client);

  final ApiClient _client;

  Future<void> submit({
    required String registrationType, // "MEMBER" | "STAKEHOLDER"
    required String name,
    required String email,
    required String phone,
    String? institution,
    String? academicDiscipline,
    String? graduatedYear,
    String? postalAddress,
    String? currentResidential,
    String? employmentStatus,
    String? levelOfEducation,
    String? employer,
    String? gender,
    String? photoPath,
  }) async {
    final form = FormData.fromMap({
      'registrationType': registrationType,
      'name': name,
      'email': email,
      'phone': phone,
      'institution': ?institution,
      'academicDiscipline': ?academicDiscipline,
      'graduatedYear': ?graduatedYear,
      'postalAddress': ?postalAddress,
      'currentResidential': ?currentResidential,
      'employmentStatus': ?employmentStatus,
      'levelOfEducation': ?levelOfEducation,
      'employer': ?employer,
      'gender': ?gender,
      if (photoPath != null) 'photo': await MultipartFile.fromFile(photoPath),
    });
    await _client.postForm('/applications', form);
  }

  Future<String> checkStatus(String email) async {
    final json = await _client.get('/applications', query: {'email': email});
    return json['status'] as String? ?? 'NONE';
  }
}
