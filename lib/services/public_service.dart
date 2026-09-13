import '../core/network/api_client.dart';
import '../models/public/about_content.dart';
import '../models/public/about_sections.dart';
import '../models/public/contact_info.dart';
import '../models/public/donate_content.dart';
import '../models/public/gallery_album.dart';
import '../models/public/home_content.dart';
import '../models/public/leadership_sections.dart';
import '../models/public/membership_content.dart';
import '../models/public/news_item.dart';
import '../models/public/project.dart';

/// Wraps the public, unauthenticated content endpoints (/api/about,
/// /api/gallery, etc.) — these mirror the website's static marketing pages
/// so they're safe to call without a signed-in session.
///
/// Every endpoint accepts a `locale` query param (mirroring the website's
/// [locale] routing / next-intl setup) and returns translated copy for it —
/// callers must pass the app's current language so content matches the UI.
class PublicService {
  PublicService(this._client);

  final ApiClient _client;

  Future<HomeContent> fetchHome({required String locale}) async {
    final json = await _client.get('/home', query: {'locale': locale});
    return HomeContent.fromJson(json);
  }

  Future<DonateContent> fetchDonate({required String locale}) async {
    final json = await _client.get('/donate', query: {'locale': locale});
    return DonateContent.fromJson(json);
  }

  Future<AboutContent> fetchAbout({required String locale}) async {
    final json = await _client.get('/about', query: {'locale': locale});
    return AboutContent.fromJson(json);
  }

  Future<VisionMissionContent> fetchVisionMission({required String locale}) async {
    final json = await _client.get('/about/vision-mission', query: {'locale': locale});
    return VisionMissionContent.fromJson(json);
  }

  Future<HistoryContent> fetchHistory({required String locale}) async {
    final json = await _client.get('/about/history', query: {'locale': locale});
    return HistoryContent.fromJson(json);
  }

  Future<ConstitutionContent> fetchConstitution({required String locale}) async {
    final json = await _client.get('/about/constitution', query: {'locale': locale});
    return ConstitutionContent.fromJson(json);
  }

  Future<List<GalleryAlbum>> fetchGallery({required String locale}) async {
    final json = await _client.get('/gallery', query: {'locale': locale});
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) => GalleryAlbum.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LeadershipOverviewContent> fetchLeadership({required String locale}) async {
    final json = await _client.get('/leadership', query: {'locale': locale});
    return LeadershipOverviewContent.fromJson(json);
  }

  Future<LeadershipGroupContent> fetchLeadershipBoard({required String locale}) async {
    final json = await _client.get('/leadership/board', query: {'locale': locale});
    return LeadershipGroupContent.fromJson(json);
  }

  Future<LeadershipGroupContent> fetchLeadershipExecutive({required String locale}) async {
    final json = await _client.get('/leadership/executive', query: {'locale': locale});
    return LeadershipGroupContent.fromJson(json);
  }

  Future<DepartmentsContent> fetchLeadershipDepartments({required String locale}) async {
    final json = await _client.get('/leadership/departments', query: {'locale': locale});
    return DepartmentsContent.fromJson(json);
  }

  Future<MembershipContent> fetchMembership({required String locale}) async {
    final json = await _client.get('/membership', query: {'locale': locale});
    return MembershipContent.fromJson(json);
  }

  Future<List<NewsItem>> fetchNews({required String locale}) async {
    final json = await _client.get('/news', query: {'locale': locale});
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) => NewsItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Project>> fetchProjects({required String locale}) async {
    final json = await _client.get('/projects', query: {'locale': locale});
    final list = json['data'] as List<dynamic>? ?? [];
    return list.map((e) => Project.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ContactInfo> fetchContact({required String locale}) async {
    final json = await _client.get('/contact', query: {'locale': locale});
    return ContactInfo.fromJson(json);
  }
}
