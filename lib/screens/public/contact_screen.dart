import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/localization/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/public_providers.dart';
import '../../widgets/state_views.dart';
import '../../widgets/app_footer.dart';

class ContactScreen extends ConsumerWidget {
  const ContactScreen({super.key});

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri);
    if (!ok && context.mounted) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.couldNotOpenLink)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactAsync = ref.watch(contactInfoProvider);
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.contactUsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(contactInfoProvider),
        child: contactAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorRetryView(message: e.toString(), onRetry: () => ref.invalidate(contactInfoProvider)),
          data: (contact) {
            final textTheme = Theme.of(context).textTheme;
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                Text(contact.heroTitle, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(contact.heroLead, style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined),
                    title: Text(contact.addressHeading),
                    subtitle: Text(contact.address),
                  ),
                ),
                for (final phone in contact.phones)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.call_outlined),
                      title: Text(phone.display),
                      subtitle: contact.phoneNote.isNotEmpty ? Text(contact.phoneNote) : null,
                      onTap: () => _launch(context, Uri(scheme: 'tel', path: phone.e164)),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_outlined),
                        tooltip: contact.whatsappHeading,
                        onPressed: () => _launch(context, Uri.parse('https://wa.me/${phone.e164}')),
                      ),
                    ),
                  ),
                if (contact.mapEmbedUrl.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.map_outlined),
                      title: Text(contact.mapHeading),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => _launch(context, Uri.parse(contact.mapEmbedUrl)),
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
