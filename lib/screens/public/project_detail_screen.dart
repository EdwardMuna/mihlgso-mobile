import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/constants/api_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../models/public/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});
  final Project project;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(project.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md + 14),
        children: [
          if (project.coverImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: CachedNetworkImage(imageUrl: ApiConfig.resolveAssetUrl(project.coverImage!), fit: BoxFit.cover),
            ),
          const SizedBox(height: AppSpacing.lg),
          Text(project.subtitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(project.intro),
          if (project.intro2.isNotEmpty) ...[const SizedBox(height: AppSpacing.sm), Text(project.intro2)],
          if (project.beneficiaries.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(strings.projectBeneficiaries, style: Theme.of(context).textTheme.titleSmall),
            Text(project.beneficiaries),
          ],
          if (project.glance.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(strings.atAGlance, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: project.glance
                  .map((g) => Chip(label: Text('${g.label}: ${g.value}')))
                  .toList(),
            ),
          ],
          if (project.phases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(strings.phases, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            for (final phase in project.phases)
              Card(
                child: ListTile(
                  title: Text(phase.title),
                  subtitle: Text(phase.description),
                  trailing: Chip(label: Text(phase.statusLabel), visualDensity: VisualDensity.compact),
                ),
              ),
          ],
          if (project.gallery.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(strings.gallery, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: project.gallery.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: CachedNetworkImage(
                    imageUrl: ApiConfig.resolveAssetUrl(project.gallery[i].src),
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],

          if (project.donation.items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(strings.supportThisProject, style: Theme.of(context).textTheme.titleSmall),
            Text(project.donation.lead),
            const SizedBox(height: AppSpacing.sm),
            for (final item in project.donation.items)
              Card(
                child: ListTile(
                  title: Text(item.title),
                  subtitle: Text(item.description),
                  trailing: Text(item.amount, style: Theme.of(context).textTheme.titleSmall),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
