import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rahbar/domain/models/auth/auth_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(const FlutterSecureStorage());
});

class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage(this._storage);

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _profileKey = 'cached_profile';

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _profileKey);
  }

  Future<void> saveCachedProfile(UserProfile profile) async {
    final Map<String, dynamic> data = profile.toJson();
    // Do NOT cache raw CNIC or medical data in plaintext if possible. We can omit or mask.
    // However, FlutterSecureStorage is encrypted on Android/iOS, so it is relatively safe
    // but the user instruction was "Persist a minimal non-sensitive profile cache... Do NOT cache raw CNIC".
    // We already receive a MASKED cnic from the backend in getProfile(), so it's already masked.
    // Medical data: we can remove it before caching if we want to be extra safe.
    data.remove('medical_conditions');
    data.remove('disability');
    
    await _storage.write(key: _profileKey, value: jsonEncode(data));
  }

  Future<UserProfile?> getCachedProfile() async {
    final str = await _storage.read(key: _profileKey);
    if (str != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(str);
        return UserProfile.fromJson(data);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
