import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/core/network/api_client.dart';
import 'package:rahbar/domain/models/auth/auth_models.dart';
import 'package:rahbar/data/storage/token_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

class AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRepository({required this.apiClient, required this.tokenStorage});

  Future<OtpRequestResponse> requestOtp(String phoneNumber) async {
    final response = await apiClient.post(
      '/auth/request-otp',
      body: {'phone_number': phoneNumber},
      requiresAuth: false,
    );
    if (response.statusCode == 200) {
      return OtpRequestResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<TokenResponse> verifyOtp(String phoneNumber, String otp) async {
    final response = await apiClient.post(
      '/auth/verify-otp',
      body: {'phone_number': phoneNumber, 'otp': otp},
      requiresAuth: false,
    );
    if (response.statusCode == 200) {
      return TokenResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<String?> getDevOtp(String phoneNumber) async {
    try {
      final response = await apiClient.get('/auth/dev/otp/$phoneNumber', requiresAuth: false);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['otp'];
      }
    } catch (_) {}
    return null;
  }

  Future<UserProfile> getProfile() async {
    final response = await apiClient.get('/profile');
    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> payload) async {
    final response = await apiClient.patch('/profile', body: payload);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }

  Future<void> logout() async {
    final refresh = await tokenStorage.getRefreshToken();
    if (refresh != null) {
      try {
        await apiClient.post('/auth/logout', body: {'refresh_token': refresh}, requiresAuth: false);
      } catch (_) {}
    }
    await tokenStorage.clearTokens();
  }
}
