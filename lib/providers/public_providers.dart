import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../services/public_service.dart';
import 'core_providers.dart';
import 'locale_provider.dart';

final publicServiceProvider = Provider<PublicService>((ref) {
  return PublicService(ref.watch(apiClientProvider));
});

// Every provider below watches localeProvider so switching the app's
// language automatically refetches this content translated for it — the
// backend's public endpoints all accept a `locale` query param.

final homeContentProvider = FutureProvider.autoDispose<HomeContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchHome(locale: locale.languageCode);
});

final donateProvider = FutureProvider.autoDispose<DonateContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchDonate(locale: locale.languageCode);
});

final aboutContentProvider = FutureProvider.autoDispose<AboutContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchAbout(locale: locale.languageCode);
});

final visionMissionProvider = FutureProvider.autoDispose<VisionMissionContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchVisionMission(locale: locale.languageCode);
});

final historyProvider = FutureProvider.autoDispose<HistoryContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchHistory(locale: locale.languageCode);
});

final constitutionProvider = FutureProvider.autoDispose<ConstitutionContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchConstitution(locale: locale.languageCode);
});

final galleryAlbumsProvider = FutureProvider.autoDispose<List<GalleryAlbum>>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchGallery(locale: locale.languageCode);
});

final leadershipProvider = FutureProvider.autoDispose<LeadershipOverviewContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchLeadership(locale: locale.languageCode);
});

final leadershipBoardProvider = FutureProvider.autoDispose<LeadershipGroupContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchLeadershipBoard(locale: locale.languageCode);
});

final leadershipExecutiveProvider = FutureProvider.autoDispose<LeadershipGroupContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchLeadershipExecutive(locale: locale.languageCode);
});

final leadershipDepartmentsProvider = FutureProvider.autoDispose<DepartmentsContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchLeadershipDepartments(locale: locale.languageCode);
});

final membershipProvider = FutureProvider.autoDispose<MembershipContent>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchMembership(locale: locale.languageCode);
});

final newsItemsProvider = FutureProvider.autoDispose<List<NewsItem>>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchNews(locale: locale.languageCode);
});

final projectsProvider = FutureProvider.autoDispose<List<Project>>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchProjects(locale: locale.languageCode);
});

final contactInfoProvider = FutureProvider.autoDispose<ContactInfo>((ref) {
  final locale = ref.watch(localeProvider);
  return ref.watch(publicServiceProvider).fetchContact(locale: locale.languageCode);
});
