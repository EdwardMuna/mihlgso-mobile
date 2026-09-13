import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import 'admin_dashboard_screen.dart';
import 'admin_applications_screen.dart';
import 'admin_members_screen.dart';
import 'admin_contribution_types_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_donations_screen.dart';
import 'admin_settings_screen.dart';
import 'mosms/mosms_home_screen.dart';

class _AdminMenuItem {
  const _AdminMenuItem(this.label, this.icon, this.selectedIcon, this.color, this.screen);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final Color color;
  final Widget screen;
}

/// Mirrors the website admin sidebar (Dashboard, Applications, Members,
/// Contribution Types, Payments, Donations, MoSMS, Settings) as a drawer,
/// with Dashboard as the landing page. Each item is tinted with the same
/// color used for its data on the admin dashboard's stat cards, so the
/// drawer reads as an index into that dashboard.
List<_AdminMenuItem> _buildMenuItems(AppStrings strings) => [
      _AdminMenuItem(strings.dashboard, Icons.dashboard_outlined, Icons.dashboard, AppColors.primary, const AdminDashboardScreen()),
      _AdminMenuItem(strings.applications, Icons.assignment_outlined, Icons.assignment, AppColors.primaryDark, const AdminApplicationsScreen()),
      _AdminMenuItem(strings.members, Icons.people_outline, Icons.people, AppColors.primary, const AdminMembersScreen()),
      _AdminMenuItem(strings.contributionTypes, Icons.category_outlined, Icons.category, AppColors.secondaryDark, const AdminContributionTypesScreen()),
      _AdminMenuItem(strings.payments, Icons.payments_outlined, Icons.payments, AppColors.secondary, const AdminPaymentsScreen()),
      _AdminMenuItem(strings.donations, Icons.volunteer_activism_outlined, Icons.volunteer_activism, AppColors.accentStrong, const AdminDonationsScreen()),
      _AdminMenuItem(strings.mosms, Icons.sms_outlined, Icons.sms, AppColors.secondary, const MoSmsHomeScreen()),
      _AdminMenuItem(strings.settings, Icons.settings_outlined, Icons.settings, AppColors.primaryDark, const AdminSettingsScreen()),
    ];

/// Which admin tab (index into [_buildMenuItems]) is currently shown. Shared
/// so e.g. the dashboard's stat cards can jump straight to a specific
/// section (Members, Applications, ...) without AdminShell owning that
/// navigation logic.
final adminTabIndexProvider = StateProvider<int>((ref) => 0);

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  // Indexes into _menuItems shown as bottom-nav destinations, in order.
  static const _bottomMenuIndexes = [0, 1, 6]; // Dashboard, Applications, MoSMS

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final menuItems = _buildMenuItems(strings);
    final index = ref.watch(adminTabIndexProvider);
    // 0 = Home (leaves the admin area), 1.. map to _bottomMenuIndexes.
    final bottomSelected = _bottomMenuIndexes.contains(index)
        ? _bottomMenuIndexes.indexOf(index) + 1
        : -1;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(menuItems[index].label),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: bottomSelected < 0 ? 0 : bottomSelected,
        onDestinationSelected: (i) {
          if (i == 0) {
            context.go('/home');
            return;
          }
          ref.read(adminTabIndexProvider.notifier).state = _bottomMenuIndexes[i - 1];
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: strings.home),
          for (final i in _bottomMenuIndexes)
            NavigationDestination(icon: Icon(menuItems[i].icon), selectedIcon: Icon(menuItems[i].selectedIcon), label: menuItems[i].label),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final user = ref.watch(authControllerProvider).valueOrNull;
                  final initial = (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'A';
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
                    decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          child: Text(
                            initial,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          user?.name ?? strings.administrator,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user?.email != null)
                          Text(
                            user!.email,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            strings.administratorAllCaps,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
                  itemCount: menuItems.length,
                  itemBuilder: (context, i) {
                    final item = menuItems[i];
                    final selected = i == index;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: selected ? 0.08 : 0),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: selected ? Border.all(color: item.color.withValues(alpha: 0.25)) : null,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor: item.color.withValues(alpha: 0.15),
                          child: Icon(selected ? item.selectedIcon : item.icon, color: item.color, size: 20),
                        ),
                        title: Text(
                          item.label,
                          style: TextStyle(
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            color: selected ? item.color : null,
                          ),
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        onTap: () {
                          ref.read(adminTabIndexProvider.notifier).state = i;
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Consumer(
                  builder: (context, ref, _) => ListTile(
                    leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                    title: Text(strings.signOut, style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                    onTap: () {
                      Navigator.of(context).pop();
                      ref.read(authControllerProvider.notifier).logout();
                      context.go('/home');
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(
        index: index,
        children: [for (final item in menuItems) item.screen],
      ),
      ),
    );
  }
}
