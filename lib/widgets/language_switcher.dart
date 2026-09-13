import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../providers/locale_provider.dart';

/// Mirrors the website's language switcher (components/controls/LanguageSwitcher.tsx):
/// a translate icon followed by EN/SW pill buttons, the active one highlighted
/// with the brand blue->green gradient.
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    Widget pill(String code, String label) {
      final selected = locale.languageCode == code;
      return GestureDetector(
        onTap: selected ? null : () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
        child: Semantics(
          label: label,
          button: true,
          selected: selected,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              gradient: selected ? AppColors.brandGradient : null,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              code.toUpperCase(),
              style: TextStyle(
                color: selected ? Colors.white : scheme.onPrimary.withValues(alpha: 0.75),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.translate, size: 16, color: scheme.onPrimary.withValues(alpha: 0.85)),
        const SizedBox(width: 3),
        pill('en', 'English'),
        const SizedBox(width: 2),
        pill('sw', 'Kiswahili'),
      ],
    );
  }
}
