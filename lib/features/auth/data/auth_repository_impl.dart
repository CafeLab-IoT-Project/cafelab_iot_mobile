import 'package:cafelab_iot_mobile/features/auth/data/auth_http_headers.dart';
import 'package:cafelab_iot_mobile/features/auth/data/auth_api_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/user_session_storage.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/auth_repository.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_in_request.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_bootstrap_orchestrator.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:flutter/foundation.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final TokenStorageService _tokenStorage;
  final UserSessionStorage _sessionStorage;
  final ProfileBootstrapOrchestrator _profileOrchestrator;
  final AuthHttpHeaders _authHttpHeaders;

  AuthRepositoryImpl({
    AuthApiService? apiService,
    TokenStorageService? tokenStorage,
    UserSessionStorage? sessionStorage,
    ProfileBootstrapOrchestrator? profileOrchestrator,
    AuthHttpHeaders? authHttpHeaders,
  })  : _apiService = apiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _sessionStorage = sessionStorage ?? UserSessionStorage(),
        _profileOrchestrator =
            profileOrchestrator ?? ProfileBootstrapOrchestrator(),
        _authHttpHeaders = authHttpHeaders ?? AuthHttpHeaders();

  @override
  Future<AuthenticatedUser> signIn(SignInRequest request) async {
    final user = await _apiService.signIn(request.email, request.password);
    await saveToken(user.token);
    await _sessionStorage.saveEmail(user.email);
    final persistedToken = await getToken();
    if (persistedToken == null || persistedToken.isEmpty) {
      throw const AuthApiException(
        'No se pudo persistir el token de sesion en el dispositivo.',
      );
    }
    debugPrint('[AuthRepositoryImpl] Token persisted after sign-in: true');
    try {
      await _profileOrchestrator.ensureProfileExistsAfterSignIn(
        user: user,
      );
    } on ProfileApiException catch (e) {
      throw AuthApiException(
        e.displayMessage,
        statusCode: e.statusCode,
      );
    }
    return user;
  }

  @override
  Future<void> registerProfile(SignUpRequest request) async {
    try {
      await _profileOrchestrator.ensureProfileExistsBeforeSignUp(
        signUpRequest: request,
      );
    } on ProfileApiException catch (e) {
      throw AuthApiException(
        e.displayMessage,
        statusCode: e.statusCode,
      );
    }
  }

  @override
  Future<AuthenticatedUser> registerAndSignIn(SignUpRequest request) async {
    await registerProfile(request);
    return signIn(
      SignInRequest(email: request.email, password: request.password),
    );
  }

  @override
  Future<void> saveToken(String token) => _tokenStorage.saveToken(token);

  @override
  Future<String?> getToken() => _tokenStorage.getToken();

  @override
  Future<void> clearToken() async {
    await _tokenStorage.clearToken();
    await _sessionStorage.clearSession();
  }

  /// Utility for future protected requests after login.
  Future<Map<String, String>> getProtectedHeaders() =>
      _authHttpHeaders.protectedJson();
}
