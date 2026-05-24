import 'dart:io';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';

class MissingAuthTokenException implements Exception {
  const MissingAuthTokenException([
    this.message = 'No hay token de sesión. Inicia sesión de nuevo.',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Encabezados HTTP con Bearer JWT para endpoints protegidos por IAM.
class AuthHttpHeaders {
  AuthHttpHeaders({TokenStorageService? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorageService();

  final TokenStorageService _tokenStorage;

  Map<String, String> publicJson() {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
    };
  }

  /// Incluye Bearer si hay token guardado (p. ej. perfiles con sesión activa).
  Future<Map<String, String>> jsonWithTokenIfPresent() async {
    final headers = publicJson();
    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  /// Bearer obligatorio para bounded contexts que exigen autenticación IAM.
  Future<Map<String, String>> protectedJson() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const MissingAuthTokenException();
    }
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }
}
