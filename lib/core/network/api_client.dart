import 'package:dio/dio.dart';

import '../constants/api_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

/// Callback invoked when the server reports the session as expired/invalid
/// (401 on an authenticated request) so the app can force a re-login.
typedef UnauthorizedCallback = void Function();

/// Thin wrapper around Dio that attaches the bearer token to every request,
/// converts every failure into an [ApiException], and never lets a raw
/// Dio/stack-trace error reach the UI.
class ApiClient {
  ApiClient(this._tokenStorage, {this.onUnauthorized})
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            headers: {'Accept': 'application/json'},
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final UnauthorizedCallback? onUnauthorized;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _guard(() => _dio.get(path, queryParameters: query));
    return _asMap(res);
  }

  Future<Map<String, dynamic>> post(String path, {Object? data}) async {
    final res = await _guard(() => _dio.post(path, data: data));
    return _asMap(res);
  }

  Future<Map<String, dynamic>> patch(String path, {Object? data}) async {
    final res = await _guard(() => _dio.patch(path, data: data));
    return _asMap(res);
  }

  Future<Map<String, dynamic>> delete(String path, {Object? data}) async {
    final res = await _guard(() => _dio.delete(path, data: data));
    return _asMap(res);
  }

  /// For multipart requests (photo/file uploads).
  Future<Map<String, dynamic>> postForm(String path, FormData form) async {
    final res = await _guard(() => _dio.post(path, data: form));
    return _asMap(res);
  }

  /// Raw bytes response (photo GET endpoints return image bytes, not JSON).
  Future<List<int>> getBytes(String path) async {
    final res = await _guard(
      () => _dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      ),
    );
    return res.data ?? const [];
  }

  Map<String, dynamic> _asMap(Response res) {
    final data = res.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'The request timed out. Check your connection and try again.',
          type: ApiExceptionType.timeout,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message:
              'Could not reach the server. Make sure you are on the same Wi-Fi network as the server.',
          type: ApiExceptionType.network,
        );
      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Could not verify the server\'s security certificate. Please try again later.',
          type: ApiExceptionType.network,
        );
      case DioExceptionType.cancel:
        return const ApiException(
          message: 'The request was cancelled.',
          type: ApiExceptionType.unknown,
        );
      case DioExceptionType.badResponse:
        break;
      default:
        return const ApiException(
          message: 'Something went wrong. Please check your connection and try again.',
          type: ApiExceptionType.network,
        );
    }

    final status = e.response?.statusCode;
    final body = e.response?.data;
    final serverMessage = (body is Map && body['error'] is String)
        ? body['error'] as String
        : null;
    Map<String, List<String>>? fieldErrors;
    if (body is Map && body['issues']?['fieldErrors'] is Map) {
      fieldErrors = (body['issues']['fieldErrors'] as Map).map(
        (k, v) => MapEntry(k.toString(), List<String>.from(v as List)),
      );
    }

    switch (status) {
      case 401:
        return ApiException(
          message: serverMessage ?? 'Invalid credentials or session expired.',
          type: ApiExceptionType.unauthorized,
          statusCode: status,
        );
      case 403:
        return ApiException(
          message: serverMessage ?? 'You do not have permission to do that.',
          type: ApiExceptionType.forbidden,
          statusCode: status,
        );
      case 404:
        return ApiException(
          message: serverMessage ?? 'Not found.',
          type: ApiExceptionType.notFound,
          statusCode: status,
        );
      case 400:
      case 422:
        return ApiException(
          message: serverMessage ?? 'Please check the form and try again.',
          type: ApiExceptionType.validation,
          statusCode: status,
          fieldErrors: fieldErrors,
        );
      case 409:
        return ApiException(
          message: serverMessage ?? 'This conflicts with existing data.',
          type: ApiExceptionType.conflict,
          statusCode: status,
        );
      case 423:
        return ApiException(
          message: serverMessage ?? 'This account is locked. Please contact an administrator.',
          type: ApiExceptionType.forbidden,
          statusCode: status,
        );
      case 429:
        return ApiException(
          message: serverMessage ?? 'Too many attempts. Please wait a moment and try again.',
          type: ApiExceptionType.unknown,
          statusCode: status,
        );
      default:
        if (status != null && status >= 500) {
          return const ApiException(
            message: 'Something went wrong on the server. Please try again later.',
            type: ApiExceptionType.server,
          );
        }
        return ApiException(
          message: serverMessage ?? 'Something went wrong. Please try again.',
          type: ApiExceptionType.unknown,
          statusCode: status,
        );
    }
  }
}
