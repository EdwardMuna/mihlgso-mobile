import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/api_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class ConstitutionScreen extends ConsumerWidget {
  const ConstitutionScreen({super.key});

  Future<void> _downloadPdf(BuildContext context, String pdfUrl) async {
    final uri = Uri.parse(ApiConfig.resolveAssetUrl(pdfUrl));
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.couldNotOpenPdf)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(constitutionProvider);
    final textTheme = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.constitution)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(constitutionProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(constitutionProvider)),
          data: (content) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(content.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(content.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: () => _downloadPdf(context, content.pdfUrl),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: Text(content.downloadButton),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(content.downloadHint, style: textTheme.bodySmall),
                const SizedBox(height: 20),
                for (final part in content.parts)
                  Card(
                    child: ExpansionTile(
                      title: Text(part.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(part.articles),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(part.body),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                const AppFooter(),
              ],
            );
          },
        ),
      ),
    );
  }
}
