import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/localization/app_strings.dart';
import '../core/theme/app_theme.dart';

/// Mirrors the website's footer (components/layout/Footer.tsx): brand
/// gradient background, org blurb, quick links, contact details, and the
/// bottom copyright/credit bar. Contact email/phones/address match the
/// site's own hardcoded lib/contact.ts constants (not API-driven there
/// either — the website's /api/contact route doesn't carry an email field).
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const _email = 'info@mihlgso.or.tz';
  static const _phones = [
    ('+255 655 942 925', '255655942925'),
    ('+255 786 552 590', '255786552590'),
  ];

  Future<void> _launch(BuildContext context, Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(strings.couldNotOpenLink)));
    }
  }

  Widget _link(BuildContext context, String label, String path) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => context.push(path),
        child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final strings = AppStrings.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.brandGradient),
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Org blurb + logo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo.jpeg',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.school, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MIHLGSO', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      strings.orgBlurb,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.registeredNgoSince,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Quick links
          Text(strings.quickLinks, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _link(context, strings.about, '/about'),
          _link(context, strings.leadershipTitle, '/leadership'),
          _link(context, strings.projects, '/projects'),
          _link(context, strings.membership, '/membership'),
          _link(context, strings.gallery, '/gallery'),
          _link(context, strings.contact, '/contact'),

          const SizedBox(height: 28),

          // Contact
          Text(strings.contact, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              Text(strings.addressMafia, style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _launch(context, Uri(scheme: 'mailto', path: _email)),
            child: const Row(
              children: [
                Icon(Icons.mail_outline, color: Colors.white70, size: 18),
                SizedBox(width: 8),
                Text(_email, style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (final phone in _phones)
            InkWell(
              onTap: () => _launch(context, Uri(scheme: 'tel', path: phone.$2)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    const Icon(Icons.call_outlined, color: Colors.white70, size: 18),
                    const SizedBox(width: 8),
                    Text(phone.$1, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 28),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // Bottom bar
          Text(strings.copyrightLine(year), style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(strings.developedByPrefix, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              InkWell(
                onTap: () => _launch(context, Uri.parse('https://moinfo.co.tz/')),
                child: const Text(
                  'MoinfoTech',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
          SizedBox(height: 32 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
