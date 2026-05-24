import 'package:cafelab_iot_mobile/features/auth/data/auth_api_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/auth_repository.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_in_request.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_bootstrap_orchestrator.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final TokenStorageService _tokenStorage;
  final ProfileBootstrapOrchestrator _profileOrchestrator;

  AuthRepositoryImpl({
    AuthApiService? apiService,
    TokenStorageService? tokenStorage,
    ProfileBootstrapOrchestrator? profileOrchestrator,
  })  : _apiService = apiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService(),
        _profileOrchestrator =
            profileOrchestrator ?? ProfileBootstrapOrchestrator();

  @override
  Future<AuthenticatedUser> signIn(SignInRequest request) async {
    final user = await _apiService.signIn(request.email, request.password);
    await saveToken(user.token);
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
  Future<void> saveToken(String token) => _tokenStorage.saveToken(token);

  @override
  Future<String?> getToken() => _tokenStorage.getToken();

  @override
  Future<void> clearToken() => _tokenStorage.clearToken();

  /// Utility for future protected requests after login.
  Future<Map<String, String>> getProtectedHeaders() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw const AuthApiException('No hay token guardado para endpoint protegido.');
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }
}
