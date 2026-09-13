import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../providers/member_providers.dart';
import 'member_dashboard_screen.dart';
import 'member_payments_screen.dart';
import 'member_donations_screen.dart';
import 'member_profile_screen.dart';
import 'record_donation_sheet.dart';
import 'record_payment_sheet.dart';

/// Shared across the shell and its tabs so e.g. the dashboard's "View all"
/// link can switch tabs without the shell owning that navigation logic.
final memberTabIndexProvider = StateProvider<int>((ref) => 0);

class MemberShell extends ConsumerWidget {
  const MemberShell({super.key});

  static const _screens = [
    MemberDashboardScreen(),
    MemberPaymentsScreen(),
    MemberDonationsScreen(),
    MemberProfileScreen(),
  ];

  Future<void> _recordPayment(BuildContext context, WidgetRef ref) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RecordPaymentSheet(),
    );
    if (saved == true) ref.invalidate(myPaymentsProvider);
  }

  Future<void> _recordDonation(BuildContext context, WidgetRef ref) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const RecordDonationSheet(),
    );
    if (saved == true) ref.invalidate(myDonationsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(memberTabIndexProvider);
    final strings = AppStrings.of(context);
    final titles = [strings.dashboard, strings.payments, strings.donations, strings.profile];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(titles[index]),
        ),
        body: IndexedStack(index: index, children: _screens),
        floatingActionButton: switch (index) {
          1 => FloatingActionButton.extended(
              onPressed: () => _recordPayment(context, ref),
              icon: const Icon(Icons.add),
              label: Text(strings.recordPayment),
            ),
          2 => FloatingActionButton.extended(
              onPressed: () => _recordDonation(context, ref),
              icon: const Icon(Icons.add),
              label: Text(strings.recordDonation),
            ),
          _ => null,
        },
        bottomNavigationBar: NavigationBar(
          // Index 2 ("Home") isn't a tab in `_screens` — it navigates to the
          // public site instead, so tab indices >2 are shifted by one below.
          selectedIndex: index < 2 ? index : index + 1,
          onDestinationSelected: (i) {
            if (i == 2) {
              context.go('/home');
            } else {
              ref.read(memberTabIndexProvider.notifier).state = i < 2 ? i : i - 1;
            }
          },
          destinations: [
            NavigationDestination(icon: const Icon(Icons.dashboard_outlined), selectedIcon: const Icon(Icons.dashboard), label: strings.dashboard),
            NavigationDestination(icon: const Icon(Icons.payments_outlined), selectedIcon: const Icon(Icons.payments), label: strings.payments),
            NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: strings.home),
            NavigationDestination(icon: const Icon(Icons.volunteer_activism_outlined), selectedIcon: const Icon(Icons.volunteer_activism), label: strings.donations),
            NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person), label: strings.profile),
          ],
        ),
      ),
    );
  }
}
