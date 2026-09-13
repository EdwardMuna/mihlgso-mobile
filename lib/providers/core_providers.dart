import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../services/application_service.dart';
import '../services/auth_service.dart';
import 'auth_provider.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// The ApiClient needs to notify the auth controller on a 401 so the app can
/// force the user back to the login screen. Riverpod's ref.read inside the
/// callback is safe here because it only fires in response to a real network
/// event, never during provider construction.
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return ApiClient(
    storage,
    onUnauthorized: () => ref.read(authControllerProvider.notifier).forceLogout(),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiClientProvider));
});

final applicationServiceProvider = Provider<ApplicationService>((ref) {
  return ApplicationService(ref.watch(apiClientProvider));
});
