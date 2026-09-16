import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/annual_subscription.dart';
import '../models/contribution_type.dart';
import '../models/donation.dart';
import '../models/leaderboard.dart';
import '../models/payment.dart';
import '../services/member_service.dart';
import 'core_providers.dart';

final memberServiceProvider = Provider<MemberService>((ref) {
  return MemberService(ref.watch(apiClientProvider));
});

final contributionTypesProvider = FutureProvider<List<ContributionType>>((ref) {
  return ref.watch(memberServiceProvider).fetchContributionTypes();
});

final myPaymentsProvider = FutureProvider.autoDispose<List<Payment>>((ref) {
  return ref.watch(memberServiceProvider).fetchMyPayments();
});

final myDonationsProvider = FutureProvider.autoDispose<List<Donation>>((ref) {
  return ref.watch(memberServiceProvider).fetchMyDonations();
});

final annualSubscriptionProvider = FutureProvider.autoDispose<AnnualSubscription?>((ref) {
  return ref.watch(memberServiceProvider).fetchAnnualSubscription();
});

final topContributorsProvider = FutureProvider.autoDispose<LeaderboardResult>((ref) {
  return ref.watch(memberServiceProvider).fetchTopContributors();
});

final allContributorsProvider = FutureProvider.autoDispose<LeaderboardResult>((ref) {
  return ref.watch(memberServiceProvider).fetchTopContributors(all: true);
});

/// [generalLabel] is the fallback project name for donations with no
/// purpose set — passed in by the UI so it's localized (portal.member
/// .dashboard.leaderboards.generalProject on the website).
final topDonorsProvider = FutureProvider.autoDispose.family<LeaderboardResult, String>((ref, generalLabel) {
  return ref.watch(memberServiceProvider).fetchTopDonors(generalLabel: generalLabel);
});

final allDonorsProvider = FutureProvider.autoDispose.family<LeaderboardResult, String>((ref, generalLabel) {
  return ref.watch(memberServiceProvider).fetchTopDonors(all: true, generalLabel: generalLabel);
});
