import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/contribution_type.dart';
import '../models/donation.dart';
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
