import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:rahbar/core/network/api_config.dart';
import 'package:rahbar/data/storage/token_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    tokenStorage: ref.watch(tokenStorageProvider),
    logger: Logger(),
  );
});

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiException(this.statusCode, this.message, [this.data]);

  @override
  String toString() => 'ApiException: $statusCode $message';
}

class ApiClient {
  final TokenStorage tokenStorage;
  final Logger logger;
  final http.Client _client;

  ApiClient({required this.tokenStorage, required this.logger})
      : _client = http.Client();

  bool _isRefreshing = false;

  Future<http.Response> get(String path, {bool requiresAuth = true}) async {
    return _request('GET', path, requiresAuth: requiresAuth);
  }

  Future<http.Response> post(String path, {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    return _request('POST', path, body: body, requiresAuth: requiresAuth);
  }

  Future<http.Response> patch(String path, {Map<String, dynamic>? body, bool requiresAuth = true}) async {
    return _request('PATCH', path, body: body, requiresAuth: requiresAuth);
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    var uri = Uri.parse('${ApiConfig.baseUrl}$path');
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await tokenStorage.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response = await _sendWithMethod(method, uri, headers, body);

    if (requiresAuth && response.statusCode == 401) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final newToken = await tokenStorage.getAccessToken();
            headers['Authorization'] = 'Bearer $newToken';
            response = await _sendWithMethod(method, uri, headers, body);
          } else {
            await tokenStorage.clearTokens();
            // Auth controller will handle logged out state 
          }
        } finally {
          _isRefreshing = false;
        }
      } else {
        // If already refreshing, another request might fail immediately.
        // We could implement a queue, but standard requires simple lock for now.
      }
    }

    if (response.statusCode >= 400 && response.statusCode != 401) {
      // Don't throw for 401, let the repository handle authentication failures
      // But we can throw for 400, 422, etc or just return and let caller handle.
      // Better to let caller handle 400s for form validation.
    }

    return response;
  }

  Future<http.Response> _sendWithMethod(String method, Uri uri, Map<String, String> headers, Map<String, dynamic>? body) async {
    final encodedBody = body != null ? jsonEncode(body) : null;
    switch (method) {
      case 'GET':
        return _client.get(uri, headers: headers);
      case 'POST':
        return _client.post(uri, headers: headers, body: encodedBody);
      case 'PATCH':
        return _client.patch(uri, headers: headers, body: encodedBody);
      case 'PUT':
        return _client.put(uri, headers: headers, body: encodedBody);
      case 'DELETE':
        return _client.delete(uri, headers: headers, body: encodedBody);
      default:
        throw Exception('Unsupported method $method');
    }
  }

  Future<bool> _refreshToken() async {
    final refresh = await tokenStorage.getRefreshToken();
    if (refresh == null) return false;

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/auth/refresh');
      final response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await tokenStorage.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
        );
        return true;
      }
      // If server explicitly rejects (e.g., 401 or 403), return false to clear tokens.
      if (response.statusCode == 401 || response.statusCode == 403) {
        return false;
      }
      // For 500s or other errors, we should probably throw so we don't clear tokens.
      throw Exception('Server error during refresh: ${response.statusCode}');
    } catch (e) {
      logger.e("Refresh token request failed", error: e);
      // Rethrow to prevent clearTokens from being called on network failure
      rethrow;
    }
  }
}
