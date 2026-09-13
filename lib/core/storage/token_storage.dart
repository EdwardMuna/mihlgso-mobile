import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure, encrypted-at-rest storage for the bearer session token.
/// Never store the token in SharedPreferences/plain files.
class TokenStorage {
  TokenStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'mihlgso_auth_token';
  static const _expiryKey = 'mihlgso_auth_token_expiry';

  Future<void> save({required String token, required DateTime expiresAt}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _expiryKey, value: expiresAt.toIso8601String());
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<DateTime?> readExpiry() async {
    final raw = await _storage.read(key: _expiryKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> hasValidToken() async {
    final token = await readToken();
    if (token == null) return false;
    final expiry = await readExpiry();
    if (expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
  }
}
