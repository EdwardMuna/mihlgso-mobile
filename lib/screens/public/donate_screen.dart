import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/api_config.dart';
import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class DonateScreen extends ConsumerWidget {
  const DonateScreen({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.couldNotOpenLink)));
    }
  }

  IconData _impactIcon(String key) {
    switch (key) {
      case 'education':
        return Icons.menu_book_outlined;
      case 'orphans':
        return Icons.favorite_outline;
      case 'office':
        return Icons.apartment_outlined;
      case 'programs':
      default:
        return Icons.volunteer_activism_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(donateProvider);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.donate)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(donateProvider),
        child: async.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(donateProvider)),
          data: (content) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Hero
                Text(content.hero.eyebrow.toUpperCase(),
                    style: textTheme.labelMedium?.copyWith(color: AppColors.accentStrong, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(content.hero.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.sm),
                Text(content.hero.lead, style: textTheme.bodyLarge),
                const SizedBox(height: AppSpacing.md),
                if (content.hero.image != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: CachedNetworkImage(
                        imageUrl: ApiConfig.resolveAssetUrl(content.hero.image!),
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                _GoldGradientButton(
                  label: content.whatsapp.button,
                  onPressed: () => _launch(context, Uri.parse(content.whatsapp.url)),
                ),

                // Impact
                const SizedBox(height: 28),
                Text(content.impactHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.impactSubheading, style: textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: content.impact.length,
                  itemBuilder: (context, i) {
                    final item = content.impact[i];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: scheme.primaryContainer,
                              child: Icon(_impactIcon(item.icon), color: scheme.primary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(item.title, style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: AppSpacing.xs),
                            Expanded(child: Text(item.body, style: textTheme.bodySmall)),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Ways to give
                const SizedBox(height: 28),
                Text(content.waysHeading, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Text(content.waysSubheading, style: textTheme.bodyMedium),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
                            const SizedBox(width: AppSpacing.sm),
                            Text(content.whatsapp.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.whatsapp.body),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                          onPressed: () => _launch(context, Uri.parse(content.whatsapp.url)),
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(content.whatsapp.button),
                        ),
                      ],
                    ),
                  ),
                ),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.call_outlined, color: scheme.primary),
                            const SizedBox(width: AppSpacing.sm),
                            Text(content.phone.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.phone.body),
                        const SizedBox(height: AppSpacing.sm),
                        for (final phone in content.phone.phones)
                          InkWell(
                            onTap: () => _launch(context, Uri(scheme: 'tel', path: phone.e164)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                              child: Text(phone.display, style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(content.phone.note, style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_outlined, color: AppColors.accentStrong),
                            const SizedBox(width: AppSpacing.sm),
                            Text(content.bank.title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(content.bank.body),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () => _launch(context, Uri.parse(content.bank.url)),
                          icon: const Icon(Icons.arrow_forward),
                          label: Text(content.bank.button),
                        ),
                      ],
                    ),
                  ),
                ),

                // Trust
                const SizedBox(height: AppSpacing.md),
                Card(
                  color: scheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.shield_outlined, color: scheme.secondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(content.trust.heading, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: AppSpacing.sm),
                              Text(content.trust.body),
                            ],
                          ),
                        ),
                      ],
                    ),
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

/// The website's header "Donate" pill: solid gold fill with a thin brand
/// blue->green gradient border. Reused here for the hero CTA.
class _GoldGradientButton extends StatelessWidget {
  const _GoldGradientButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
