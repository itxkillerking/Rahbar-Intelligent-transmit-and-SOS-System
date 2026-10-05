import 'package:flutter_test/flutter_test.dart';
import 'package:rahbar/application/auth/auth_controller.dart';
import 'package:rahbar/data/repositories/auth_repository.dart';
import 'package:rahbar/data/storage/token_storage.dart';
import 'package:rahbar/domain/models/auth/auth_models.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository mockRepository;
  late MockTokenStorage mockStorage;
  late AuthController controller;

  setUp(() {
    mockRepository = MockAuthRepository();
    mockStorage = MockTokenStorage();
    when(() => mockStorage.getRefreshToken()).thenAnswer((_) async => null);
    controller = AuthController(repository: mockRepository, storage: mockStorage);
  });

  test('Initial state is checkingSession and resolves to unauthenticated if no tokens', () async {
    expect(controller.debugState.status, AuthState.checkingSession);
    await controller.checkSession();
    expect(controller.debugState.status, AuthState.unauthenticated);
  });

  test('requestOtp transitions state and calls repository', () async {
    when(() => mockRepository.requestOtp(any())).thenAnswer((_) async => OtpRequestResponse(message: 'OK', expiresIn: 60, resendAfter: 60));
    await controller.requestOtp('03001234567');
    expect(controller.debugState.status, AuthState.otpRequested);
    expect(controller.debugState.phoneNumber, '03001234567');
    verify(() => mockRepository.requestOtp('03001234567')).called(1);
  });

  test('verifyOtp new user transitions to profileRequired', () async {
    controller = AuthController(repository: mockRepository, storage: mockStorage);
    // Force state
    controller.requestOtp('03001234567'); // We need phone number in state, though it will mock fail or pass depending on setup
    
    when(() => mockRepository.requestOtp(any())).thenAnswer((_) async => OtpRequestResponse(message: 'OK', expiresIn: 60, resendAfter: 60));
    await controller.requestOtp('03001234567');

    when(() => mockRepository.verifyOtp(any(), any())).thenAnswer((_) async => TokenResponse(
          accessToken: 'acc',
          refreshToken: 'ref',
          tokenType: 'bearer',
          isNewUser: true,
          profileCompleted: false,
          nextStep: 'complete_profile',
        ));
    when(() => mockStorage.saveTokens(accessToken: any(named: 'accessToken'), refreshToken: any(named: 'refreshToken')))
        .thenAnswer((_) async => null);

    await controller.verifyOtp('123456');

    expect(controller.debugState.status, AuthState.profileRequired);
    verify(() => mockStorage.saveTokens(accessToken: 'acc', refreshToken: 'ref')).called(1);
  });

  test('submitProfile transitions to authenticated on success', () async {
    when(() => mockRepository.updateProfile(any())).thenAnswer((_) async => {'profile_completed': true});
    
    await controller.submitProfile({'full_name': 'Test'});
    expect(controller.debugState.status, AuthState.authenticated);
  });

  test('logout clears state and calls repository', () async {
    when(() => mockRepository.logout()).thenAnswer((_) async => null);
    
    await controller.logout();
    
    expect(controller.debugState.status, AuthState.unauthenticated);
    verify(() => mockRepository.logout()).called(1);
  });
}
