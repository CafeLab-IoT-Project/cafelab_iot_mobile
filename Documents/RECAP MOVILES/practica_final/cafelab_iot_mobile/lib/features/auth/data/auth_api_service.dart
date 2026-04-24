import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/api_message_error.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiMessageError? apiError;

  const AuthApiException(this.message, {this.statusCode, this.apiError});

  @override
  String toString() {
    final resolvedMessage = apiError?.message ?? message;
    return statusCode == null
        ? resolvedMessage
        : '$resolvedMessage (HTTP $statusCode)';
  }
}

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  Uri _buildUri(String endpoint) =>
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authBasePath}$endpoint');

  Future<AuthenticatedUser> signIn(String email, String password) async {
    return _postAuth(
      endpoint: '/sign-in',
      body: {
        'email': email,
        'password': password,
      },
      expectedStatus: HttpStatus.ok,
      actionLabel: 'sign-in',
    );
  }

  Future<AuthenticatedUser> signUp(
    String email,
    String password,
    String role,
  ) async {
    return _postAuth(
      endpoint: '/sign-up',
      body: {
        'email': email,
        'password': password,
        'role': role,
      },
      expectedStatus: HttpStatus.created,
      actionLabel: 'sign-up',
    );
  }

  Future<AuthenticatedUser> _postAuth({
    required String endpoint,
    required Map<String, dynamic> body,
    required int expectedStatus,
    required String actionLabel,
  }) async {
    final uri = _buildUri(endpoint);
    final payload = jsonEncode(body);
    // Auth endpoints are public: no Bearer token should be sent here.
    final headers = <String, String>{
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    // Basic debug logs for integration testing.
    debugPrint('[AuthApiService][$actionLabel] POST $uri');
    debugPrint(
      '[AuthApiService][$actionLabel] Authorization: NONE (public endpoint)',
    );
    debugPrint('[AuthApiService][$actionLabel] body: $payload');

    late http.Response response;
    try {
      response = await _client
          .post(uri, headers: headers, body: payload)
          .timeout(const Duration(seconds: 15));
    } on SocketException {
      throw const AuthApiException(
        'No se pudo conectar con el backend. Verifica host/puerto y que el servidor esté levantado.',
      );
    } on HttpException {
      throw const AuthApiException(
        'Error HTTP durante la solicitud de autenticación.',
      );
    } on FormatException {
      throw const AuthApiException(
        'Respuesta inválida del servidor (JSON malformado).',
      );
    } on TimeoutException {
      throw const AuthApiException(
        'Tiempo de espera agotado. El backend tardó demasiado en responder.',
      );
    } catch (e) {
      throw AuthApiException('Error inesperado en autenticación: $e');
    }

    debugPrint('[AuthApiService][$actionLabel] status: ${response.statusCode}');
    debugPrint('[AuthApiService][$actionLabel] response: ${response.body}');

    if (response.statusCode == expectedStatus || response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return AuthenticatedUser.fromJson(decoded);
    }

    throw _mapStatusToException(
      statusCode: response.statusCode,
      responseBody: response.body,
    );
  }

  AuthApiException _mapStatusToException({
    required int statusCode,
    required String responseBody,
  }) {
    ApiMessageError? apiError;
    if (responseBody.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          apiError = ApiMessageError.fromJson(decoded);
        }
      } catch (_) {
        // Ignore parse errors and fallback to default messages.
      }
    }

    switch (statusCode) {
      case HttpStatus.badRequest:
        return AuthApiException(
          'Solicitud inválida (400). Revisa email, password o role.',
          statusCode: HttpStatus.badRequest,
          apiError: apiError,
        );
      case HttpStatus.notFound:
        return AuthApiException(
          'Credenciales inválidas o usuario no encontrado (404).',
          statusCode: HttpStatus.notFound,
          apiError: apiError,
        );
      case HttpStatus.unauthorized:
        return AuthApiException(
          'No autorizado (401).',
          statusCode: HttpStatus.unauthorized,
          apiError: apiError,
        );
      case HttpStatus.internalServerError:
        return AuthApiException(
          'Error interno del backend (500).',
          statusCode: HttpStatus.internalServerError,
          apiError: apiError,
        );
      default:
        return AuthApiException(
          'Error de autenticación no controlado.',
          statusCode: statusCode,
          apiError: apiError,
        );
    }
  }
}
