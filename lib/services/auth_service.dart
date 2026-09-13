import '../core/network/api_client.dart';
import '../models/user.dart';

class LoginResult {
  const LoginResult({required this.token, required this.expiresAt, required this.user});

  final String token;
  final DateTime expiresAt;
  final AppUser user;
}

/// Thin wrapper over the /api/auth/* and /api/me endpoints.
class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<LoginResult> login({required String email, required String password}) async {
    final json = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return LoginResult(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      user: AppUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }

  Future<AppUser> fetchCurrentUser() async {
    final json = await _client.get('/me');
    return AppUser.fromJson(json['user'] as Map<String, dynamic>);
  }
}
