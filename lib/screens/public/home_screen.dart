import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/api_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/public/home_content.dart';
import '../../providers/auth_provider.dart';
import '../../providers/public_providers.dart';
import '../../providers/theme_mode_provider.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/public_content_drawer.dart';
import '../../widgets/state_views.dart';
import 'gallery_screen.dart';
import 'news_screen.dart';
import 'projects_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  IconData _pillarIcon(String key) {
    switch (key) {
      case 'education':
        return Icons.school_outlined;
      case 'orphans':
        return Icons.favorite_outline;
      case 'community':
      default:
        return Icons.groups_outlined;
    }
  }

  IconData _involveIcon(String key) {
    switch (key) {
      case 'donate':
        return Icons.favorite_outline;
      case 'member':
        return Icons.person_add_alt_outlined;
      case 'partner':
      default:
        return Icons.handshake_outlined;
    }
  }

  void _openInvolveTarget(BuildContext context, String key) {
    switch (key) {
      case 'member':
        context.push('/apply');
        break;
      case 'donate':
        context.push('/donate');
        break;
      case 'partner':
      default:
        context.push('/contact');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeContentProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen(sessionExpiredProvider, (previous, next) {
      if (next) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.sessionExpiredDueToInactivity)),
        );
        ref.read(sessionExpiredProvider.notifier).state = false;
      }
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 4,
        title: Text(strings.appTitle, overflow: TextOverflow.ellipsis),
        actions: [
          const LanguageSwitcher(),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            constraints: const BoxConstraints(),
            tooltip: themeMode == ThemeMode.dark ? 'Switch to light theme' : 'Switch to dark theme',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              color: scheme.onPrimary,
              size: 20,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: () => context.go('/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    strings.signIn,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const PublicContentDrawer(),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(homeContentProvider),
        child: homeAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(homeContentProvider)),
          data: (home) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                // Hero
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        home.hero.trust.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(
                          color: AppColors.accentStrong,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        home.hero.title,
                        style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(home.hero.tagline, style: textTheme.bodyLarge),
                      const SizedBox(height: AppSpacing.md),
                      if (home.hero.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: ApiConfig.resolveAssetUrl(home.hero.image!),
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(color: scheme.surfaceContainerHighest),
                              errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: Colors.black),
                              onPressed: () => context.push('/donate'),
                              icon: const Icon(Icons.favorite_outline),
                              label: Text(strings.donate),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.push('/about'),
                              child: Text(strings.learnMore),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: _HeroStatTile(stat: home.hero.members)),
                          Expanded(child: _HeroStatTile(stat: home.hero.projects)),
                          Expanded(child: _HeroStatTile(stat: home.hero.since)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Our Story
                Container(
                  color: scheme.brightness == Brightness.dark ? AppColors.bgSurfaceDark : AppColors.bgSurfaceLight,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (home.story.image != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: CachedNetworkImage(
                              imageUrl: ApiConfig.resolveAssetUrl(home.story.image!),
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        home.story.eyebrow.toUpperCase(),
                        style: textTheme.labelMedium?.copyWith(color: AppColors.accentStrong, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(home.story.heading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: AppSpacing.sm),
                      Text(home.story.body, style: textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: home.story.principles
                            .map((p) => Chip(avatar: const Icon(Icons.auto_awesome, size: 16), label: Text(p)))
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(onPressed: () => context.push('/about'), child: Text(strings.learnMoreAboutUs)),
                    ],
                  ),
                ),

                // Pillars
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(home.pillarsHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(home.pillarsSubheading, style: textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      for (final pillar in home.pillars)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(_pillarIcon(pillar.icon), color: scheme.primary),
                            ),
                            title: Text(pillar.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(pillar.body),
                          ),
                        ),
                    ],
                  ),
                ),

                // Current Projects
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(home.currentProjectsHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold))),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectsScreen())),
                            child: Text(strings.viewAll),
                          ),
                        ],
                      ),
                      for (final project in home.currentProjects)
                        Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProjectsScreen())),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (project.image != null)
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: CachedNetworkImage(
                                      imageUrl: ApiConfig.resolveAssetUrl(project.image!),
                                      fit: BoxFit.cover,
                                      errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(project.subtitle.toUpperCase(), style: textTheme.labelSmall?.copyWith(color: AppColors.accentStrong)),
                                      Text(project.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(project.summary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Highlights
                Container(
                  color: scheme.brightness == Brightness.dark ? AppColors.bgSurfaceDark : AppColors.bgSurfaceLight,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(home.highlights.eyebrow.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: AppColors.accentStrong, fontWeight: FontWeight.bold)),
                                Text(home.highlights.heading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GalleryScreen())),
                            child: Text(strings.seeGallery),
                          ),
                        ],
                      ),
                      Text(home.highlights.body, style: textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: home.highlights.images.length,
                        itemBuilder: (context, i) {
                          final img = home.highlights.images[i];
                          return GestureDetector(
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GalleryScreen())),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              child: CachedNetworkImage(
                                imageUrl: ApiConfig.resolveAssetUrl(img.src),
                                fit: BoxFit.cover,
                                errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Get Involved
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(home.getInvolvedEyebrow.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: AppColors.accentStrong, fontWeight: FontWeight.bold)),
                      Text(home.getInvolvedHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text(home.getInvolvedSubheading, style: textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      for (final item in home.getInvolved)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: scheme.secondaryContainer,
                              child: Icon(_involveIcon(item.icon), color: scheme.secondary),
                            ),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(item.body),
                            onTap: () => _openInvolveTarget(context, item.icon),
                          ),
                        ),
                    ],
                  ),
                ),

                // Journey
                Container(
                  color: scheme.brightness == Brightness.dark ? AppColors.bgSurfaceDark : AppColors.bgSurfaceLight,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(home.journeyEyebrow.toUpperCase(), style: textTheme.labelMedium?.copyWith(color: AppColors.accentStrong, fontWeight: FontWeight.bold)),
                      Text(home.journeyHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      for (final milestone in home.journeyMilestones)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(milestone.year)),
                            title: Text(milestone.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(milestone.body),
                          ),
                        ),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewsScreen()),
                        ),
                        child: Text(strings.moreNews),
                      ),
                    ],
                  ),
                ),

                // Donate CTA band
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: const BoxDecoration(gradient: AppColors.brandGradient),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        home.donateCta.heading,
                        style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(home.donateCta.body, style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white70, width: 2),
                        ),
                        onPressed: () => context.push('/donate'),
                        child: Text(strings.makeADonation),
                      ),
                    ],
                  ),
                ),

                const AppFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroStatTile extends StatelessWidget {
  const _HeroStatTile({required this.stat});
  final HeroStat stat;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stat.value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(stat.label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
