import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/api_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.projects)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(projectsProvider),
        child: projectsAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(projectsProvider)),
          data: (projects) {
            if (projects.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  EmptyView(message: strings.noProjectsYet, icon: Icons.workspaces_outlined),
                  const SizedBox(height: 20),
                  const AppFooter(),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: projects.length + 1,
              itemBuilder: (context, i) {
                if (i == projects.length) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: AppFooter(),
                  );
                }
                final p = projects[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ProjectDetailScreen(project: p)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (p.coverImage != null)
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: ApiConfig.resolveAssetUrl(p.coverImage!),
                              fit: BoxFit.cover,
                              errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(p.title, style: Theme.of(context).textTheme.titleMedium)),
                                  Chip(label: Text(p.statusLabel), visualDensity: VisualDensity.compact),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(p.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
