import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';

/// Shared nav drawer for public (unauthenticated) screens — mirrors the
/// website header's "About/Leadership/Projects/Get Involved" links.
class PublicContentDrawer extends StatelessWidget {
  const PublicContentDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    Widget item(IconData icon, String label, String path, {Color? color}) {
      final tint = color ?? scheme.primary;
      return ListTile(
        leading: CircleAvatar(radius: 18, backgroundColor: tint.withValues(alpha: 0.15), child: Icon(icon, color: tint, size: 20)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        onTap: () {
          Navigator.of(context).pop();
          context.push(path);
        },
      );
    }

    Widget subItem(String label, String path) {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 56, right: AppSpacing.md),
        title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        onTap: () {
          Navigator.of(context).pop();
          context.push(path);
        },
      );
    }

    Widget expansion({required IconData icon, required String title, required Color color, required List<Widget> children}) {
      return ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: CircleAvatar(radius: 18, backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        childrenPadding: EdgeInsets.zero,
        children: children,
      );
    }

    Widget sectionLabel(String text) => Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.bold,
                ),
          ),
        );

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.lg),
              decoration: const BoxDecoration(gradient: AppColors.brandGradient),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: AssetImage('assets/images/logo.jpeg'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'MIHLGSO',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings.orgTagline,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11, height: 1.3),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 13, color: Colors.white.withValues(alpha: 0.85)),
                      const SizedBox(width: 6),
                      Text('info@mihlgso.or.tz', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Column(
                children: [
                  item(Icons.home_outlined, strings.home, '/home', color: scheme.primary),
                  item(Icons.favorite, strings.donate, '/donate', color: AppColors.accentStrong),
                ],
              ),
            ),
            sectionLabel(strings.about),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: Column(
                  children: [
                    expansion(
                      icon: Icons.info_outline,
                      title: strings.aboutMihlgso,
                      color: AppColors.primary,
                      children: [
                        subItem(strings.overview, '/about'),
                        subItem(strings.visionMission, '/about/vision-mission'),
                        subItem(strings.history, '/about/history'),
                        subItem(strings.constitution, '/about/constitution'),
                      ],
                    ),
                    expansion(
                      icon: Icons.groups_outlined,
                      title: strings.leadershipTitle,
                      color: AppColors.primaryDark,
                      children: [
                        subItem(strings.overview, '/leadership'),
                        subItem(strings.board, '/leadership/board'),
                        subItem(strings.executive, '/leadership/executive'),
                        subItem(strings.departments, '/leadership/departments'),
                      ],
                    ),
                    expansion(
                      icon: Icons.volunteer_activism_outlined,
                      title: strings.getInvolved,
                      color: AppColors.secondary,
                      children: [
                        subItem(strings.membership, '/membership'),
                        subItem(strings.newsAndEvents, '/news'),
                        subItem(strings.gallery, '/gallery'),
                        subItem(strings.contact, '/contact'),
                      ],
                    ),
                    item(Icons.workspaces_outlined, strings.projects, '/projects', color: AppColors.secondaryDark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
