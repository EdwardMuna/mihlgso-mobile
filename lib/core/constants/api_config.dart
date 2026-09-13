/// Backend base URL configuration.
///
/// Defaults to the live production site (mihlgso.or.tz), which serves API
/// routes at the domain root — no "/mihlgso" basePath in production (that
/// prefix only exists for the developer's local XAMPP folder layout, see
/// lib/basePath.ts in the Next.js project).
///
/// For local development against the Next.js dev server instead, override
/// with the developer machine's LAN IP (not `localhost` — on-device that
/// would refer to the phone itself, not the PC):
///   flutter run --dart-define=API_BASE_URL=http://LAN_IP:3000/api
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://mihlgso.or.tz/api',
  );

  static const Duration connectTimeout = Duration(seconds: 15);

  // The admin members list embeds every member's photo as base64 in the
  // same response (see AdminMember.photoDataUrl), so with enough members
  // holding photos this payload can run into several MB — a short timeout
  // here would abort the whole list fetch, not just the slow part of it.
  static const Duration receiveTimeout = Duration(seconds: 60);

  /// Public-content API responses return image `src` values as site-relative
  /// paths (e.g. `/mihlgso/_next/static/media/xyz.jpg`), the same way the
  /// Next.js app serves its own static assets. Resolve one against the
  /// current [baseUrl]'s scheme/host/port so `Image.network` can load it.
  static String resolveAssetUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final origin = Uri.parse(baseUrl);
    return origin.replace(path: path, query: '').toString();
  }
}
