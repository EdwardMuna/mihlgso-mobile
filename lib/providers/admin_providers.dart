import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/admin_member.dart';
import '../models/contribution_type.dart';
import '../models/donation.dart';
import '../models/member_application.dart';
import '../models/org_stats.dart';
import '../models/payment.dart';
import '../services/admin_service.dart';
import 'core_providers.dart';
import 'member_providers.dart';

final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService(ref.watch(apiClientProvider));
});

final adminApplicationsProvider =
    FutureProvider.autoDispose<List<MemberApplicationSummary>>((ref) {
  return ref.watch(adminServiceProvider).fetchApplications(status: 'PENDING');
});

final adminMembersProvider = FutureProvider.autoDispose<List<AdminMember>>((ref) {
  return ref.watch(adminServiceProvider).fetchMembers();
});

final adminOrgStatsProvider = FutureProvider.autoDispose<OrgStats>((ref) {
  return ref.watch(adminServiceProvider).fetchOrgStats();
});

/// All payments/donations — the backend returns every record (not just the
/// caller's own) when the signed-in user is an admin, so this simply reuses
/// the member-facing list endpoints via [MemberService].
final adminPaymentsProvider = FutureProvider.autoDispose<List<Payment>>((ref) {
  return ref.watch(memberServiceProvider).fetchMyPayments();
});

final adminDonationsProvider = FutureProvider.autoDispose<List<Donation>>((ref) {
  return ref.watch(memberServiceProvider).fetchMyDonations();
});

final adminContributionTypesProvider = FutureProvider.autoDispose<List<ContributionType>>((ref) {
  return ref.watch(adminServiceProvider).fetchContributionTypes();
});
