import 'package:cafelab_iot_mobile/features/auth/data/auth_api_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/auth_repository.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_in_request.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';
import 'dart:io';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final TokenStorageService _tokenStorage;

  AuthRepositoryImpl({
    AuthApiService? apiService,
    TokenStorageService? tokenStorage,
  })  : _apiService = apiService ?? AuthApiService(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  @override
  Future<AuthenticatedUser> signIn(SignInRequest request) async {
    final user = await _apiService.signIn(request);
    await saveToken(user.token);
    return user;
  }

  @override
  Future<AuthenticatedUser> signUp(SignUpRequest request) async {
    final user = await _apiService.signUp(request);
    await saveToken(user.token);
    return user;
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
