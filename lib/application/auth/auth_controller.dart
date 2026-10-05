import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rahbar/data/repositories/auth_repository.dart';
import 'package:rahbar/data/storage/token_storage.dart';
import 'package:rahbar/domain/models/auth/auth_models.dart';

enum AuthState {
  checkingSession,
  unauthenticated,
  requestingOtp,
  otpRequested,
  verifyingOtp,
  authenticated,
  profileRequired,
  error,
}

class AuthStateData {
  final AuthState status;
  final String? phoneNumber;
  final String? errorMessage;
  final UserProfile? profile;
  final bool isProfileLoading;
  final String? profileError;

  AuthStateData({
    this.status = AuthState.checkingSession,
    this.phoneNumber,
    this.errorMessage,
    this.profile,
    this.isProfileLoading = false,
    this.profileError,
  });

  AuthStateData copyWith({
    AuthState? status,
    String? phoneNumber,
    String? errorMessage,
    UserProfile? profile,
    bool? isProfileLoading,
    String? profileError,
  }) {
    return AuthStateData(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage, 
      profile: profile ?? this.profile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
      profileError: profileError,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthStateData>((ref) {
  return AuthController(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(tokenStorageProvider),
  )..checkSession();
});

class AuthController extends StateNotifier<AuthStateData> {
  final AuthRepository repository;
  final TokenStorage storage;

  AuthController({required this.repository, required this.storage}) : super(AuthStateData());

  Future<void> checkSession() async {
    state = state.copyWith(status: AuthState.checkingSession);
    
    final refresh = await storage.getRefreshToken();
    if (refresh == null) {
      state = state.copyWith(status: AuthState.unauthenticated);
      return;
    }

    // Try to load cached profile first for fast offline startup
    final cachedProfile = await storage.getCachedProfile();
    if (cachedProfile != null) {
      if (cachedProfile.profileCompleted) {
        state = state.copyWith(status: AuthState.authenticated, profile: cachedProfile);
      } else {
        state = state.copyWith(status: AuthState.profileRequired, profile: cachedProfile);
      }
    }

    try {
      final profile = await repository.getProfile();
      await storage.saveCachedProfile(profile);
      if (profile.profileCompleted) {
        state = state.copyWith(status: AuthState.authenticated, profile: profile);
      } else {
        state = state.copyWith(status: AuthState.profileRequired, profile: profile);
      }
    } catch (e) {
      // If we caught an Exception from apiClient that was NOT 401/403, we should preserve session.
      // If it's a 401/403, our API client might throw, or we handle it based on if tokens are cleared.
      // Wait, api_client's _refreshToken now clears tokens if 401/403.
      // Let's check if the refresh token is still there. If it's gone, it means we logged out.
      final currentRefresh = await storage.getRefreshToken();
      if (currentRefresh == null) {
        state = state.copyWith(status: AuthState.unauthenticated);
      } else {
        // Network error, we can trust the local session (Offline Mode)
        // If we don't have a cached profile, we might have to stay in checkingSession or fallback.
        if (cachedProfile == null) {
          state = state.copyWith(status: AuthState.authenticated); 
        }
      }
    }
  }

  Future<void> requestOtp(String phoneNumber) async {
    state = state.copyWith(status: AuthState.requestingOtp, phoneNumber: phoneNumber, errorMessage: null);
    try {
      await repository.requestOtp(phoneNumber);
      state = state.copyWith(status: AuthState.otpRequested, phoneNumber: phoneNumber);
    } catch (e) {
      // Simple error parsing
      String msg = "Unable to connect. Check your internet connection and try again.";
      if (e.toString().contains("429")) {
        msg = "Too many requests. Please try again shortly.";
      } else if (e.toString().contains("422")) {
        msg = "Please enter a valid phone number.";
      } else if (e.toString().contains("503")) {
        msg = "OTP service is temporarily unavailable.";
      }
      state = state.copyWith(status: AuthState.unauthenticated, errorMessage: msg);
    }
  }

  Future<void> verifyOtp(String otp) async {
    final phone = state.phoneNumber;
    if (phone == null) return;

    state = state.copyWith(status: AuthState.verifyingOtp, errorMessage: null);
    try {
      final response = await repository.verifyOtp(phone, otp);
      await storage.saveTokens(
        accessToken: response.accessToken, 
        refreshToken: response.refreshToken
      );

      if (response.nextStep == 'complete_profile') {
        state = state.copyWith(status: AuthState.profileRequired);
      } else {
        state = state.copyWith(status: AuthState.authenticated);
        loadProfile(); // fetch in background
      }
    } catch (e) {
      String msg = "Invalid or expired OTP.";
      final errorStr = e.toString();
      
      if (errorStr.contains("403")) {
        msg = "Account is currently unavailable.";
      } else if (errorStr.contains("500") || 
                 errorStr.contains("TimeoutException") || 
                 errorStr.contains("SocketException") ||
                 errorStr.contains("503") ||
                 errorStr.contains("504")) {
        msg = "Unable to verify OTP right now. Please try again.";
      }
      
      state = state.copyWith(status: AuthState.otpRequested, errorMessage: msg);
    }
  }

  bool _isProfileUpdating = false;

  Future<void> submitProfile(Map<String, dynamic> payload) async {
    if (_isProfileUpdating) return;
    _isProfileUpdating = true;
    try {
      final res = await repository.updateProfile(payload);
      if (res['profile_completed'] == true) {
        state = state.copyWith(status: AuthState.authenticated);
        loadProfile(); // refresh profile state
      } else {
        state = state.copyWith(status: AuthState.profileRequired, errorMessage: "Please fill all required fields");
      }
    } catch (e) {
      String msg = "Failed to update profile";
      if (e.toString().contains("409")) msg = "Username or CNIC already in use.";
      state = state.copyWith(status: AuthState.profileRequired, errorMessage: msg);
    } finally {
      _isProfileUpdating = false;
    }
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isProfileLoading: true, profileError: null);
    try {
      final profile = await repository.getProfile();
      await storage.saveCachedProfile(profile);
      state = state.copyWith(
        isProfileLoading: false,
        profile: profile,
        status: profile.profileCompleted ? AuthState.authenticated : AuthState.profileRequired,
      );
    } catch (e) {
      state = state.copyWith(
        isProfileLoading: false,
        profileError: "Unable to load your profile.",
      );
      // Re-check if tokens were cleared due to 401
      final currentRefresh = await storage.getRefreshToken();
      if (currentRefresh == null) {
        state = state.copyWith(status: AuthState.unauthenticated);
      }
    }
  }

  Future<void> logout() async {
    if (kDebugMode) debugPrint('AUTH: explicit logout from Settings/Drawer');
    await repository.logout();
    state = AuthStateData(status: AuthState.unauthenticated);
  }

  void cancelOtpProcess() {
    state = AuthStateData(status: AuthState.unauthenticated);
  }
}
