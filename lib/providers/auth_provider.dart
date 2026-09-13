import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'core_providers.dart';

/// Authentication state for the whole app. `AsyncValue<AppUser?>`:
/// - loading: checking for a persisted session on app start
/// - data(null): signed out
/// - data(user): signed in
/// - error: last login/refresh attempt failed (message shown, then cleared)
class AuthController extends AsyncNotifier<AppUser?> {
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);
  AuthService get _authService => ref.read(authServiceProvider);

  @override
  Future<AppUser?> build() async {
    final hasValidToken = await _tokenStorage.hasValidToken();
    if (!hasValidToken) return null;
    try {
      return await _authService.fetchCurrentUser();
    } on ApiException {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    ref.read(isLoggingInProvider.notifier).state = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final result = await _authService.login(email: email, password: password);
      await _tokenStorage.save(token: result.token, expiresAt: result.expiresAt);
      return result.user;
    });
    ref.read(isLoggingInProvider.notifier).state = false;
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } on ApiException {
      // Bearer tokens are stateless server-side — a failed logout call still
      // means the client should forget the token.
    }
    await _tokenStorage.clear();
    state = const AsyncData(null);
  }

  /// Called by ApiClient when any request comes back 401 (expired/invalid
  /// token) so the UI immediately reflects a signed-out state.
  void forceLogout() {
    _tokenStorage.clear();
    state = const AsyncData(null);
  }

  Future<void> refreshUser() async {
    state = await AsyncValue.guard(() => _authService.fetchCurrentUser());
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AppUser?>(
  AuthController.new,
);

/// True while a login() call is in flight. The router's redirect logic
/// reads this (rather than trying to infer "on the login screen" from
/// go_router's own matchedLocation, which doesn't reliably reflect the
/// current screen when redirect is re-run via refreshListenable) so it
/// doesn't yank the user off the login screen mid-attempt.
final isLoggingInProvider = StateProvider<bool>((ref) => false);

/// Set by [IdleSessionGuard] right before it force-logs-out an idle session,
/// so the login screen can show why it landed there. Reset to false once
/// shown.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);
