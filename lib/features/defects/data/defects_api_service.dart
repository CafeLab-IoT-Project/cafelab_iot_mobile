import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/api_message_error.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/defect_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DefectsApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiMessageError? apiError;

  const DefectsApiException(this.message, {this.statusCode, this.apiError});

  String get displayMessage => apiError?.message ?? message;

  @override
  String toString() =>
      statusCode == null ? displayMessage : '$displayMessage (HTTP $statusCode)';
}

class DefectsApiService {
  DefectsApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _defectsUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/defects');

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const DefectsApiException(
        'No hay token de sesión. Inicia sesión antes de usar Defects.',
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<DefectModel> createDefect(CreateDefectRequest request) async {
    final headers = await _authHeaders();
    final payload = jsonEncode(request.toJson());
    return _requestOne(
      method: 'POST',
      uri: _defectsUri,
      headers: headers,
      expectedCode: HttpStatus.created,
      body: payload,
    );
  }

  Future<List<DefectModel>> getDefects() async {
    final headers = await _authHeaders();
    return _requestMany(
      method: 'GET',
      uri: _defectsUri,
      headers: headers,
      expectedCode: HttpStatus.ok,
    );
  }

  Future<DefectModel> getDefectById(int defectId) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('${_defectsUri.toString()}/$defectId');
    return _requestOne(
      method: 'GET',
      uri: uri,
      headers: headers,
      expectedCode: HttpStatus.ok,
    );
  }

  Future<DefectModel> _requestOne({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required int expectedCode,
    String? body,
  }) async {
    final response = await _send(
      method: method,
      uri: uri,
      headers: headers,
      body: body,
    );
    if (response.statusCode == expectedCode) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return DefectModel.fromJson(decoded);
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<List<DefectModel>> _requestMany({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    required int expectedCode,
  }) async {
    final response = await _send(method: method, uri: uri, headers: headers);
    if (response.statusCode == expectedCode) {
      if (response.body.trim().isEmpty) return [];
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(DefectModel.fromJson)
            .toList();
      }
      return [];
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    debugPrint('[DefectsApiService] $method $uri');
    debugPrint(
      '[DefectsApiService] Authorization present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) {
      debugPrint('[DefectsApiService] body: $body');
    }

    try {
      final response = switch (method) {
        'POST' => await _client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 15)),
        'GET' => await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
        _ => throw const DefectsApiException('Método HTTP no soportado'),
      };

      debugPrint('[DefectsApiService] status: ${response.statusCode}');
      debugPrint('[DefectsApiService] response: ${response.body}');
      return response;
    } on SocketException {
      throw const DefectsApiException(
        'No se pudo conectar con el backend. Revisa host/puerto.',
      );
    } on TimeoutException {
      throw const DefectsApiException(
        'Tiempo de espera agotado al consumir Defects.',
      );
    }
  }

  DefectsApiException _mapHttpError(int statusCode, String responseBody) {
    ApiMessageError? apiError;
    if (responseBody.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(responseBody);
        if (decoded is Map<String, dynamic>) {
          apiError = ApiMessageError.fromJson(decoded);
        }
      } catch (_) {}
    }

    switch (statusCode) {
      case HttpStatus.unauthorized:
        return DefectsApiException(
          'Usuario no autenticado o perfil no encontrado. Vuelve a iniciar sesión y verifica que el perfil exista.',
          statusCode: statusCode,
          apiError: apiError,
        );
      case HttpStatus.badRequest:
        return DefectsApiException(
          'Solicitud inválida al crear defecto.',
          statusCode: statusCode,
          apiError: apiError,
        );
      case HttpStatus.notFound:
        return DefectsApiException(
          'Defecto no encontrado.',
          statusCode: statusCode,
          apiError: apiError,
        );
      default:
        return DefectsApiException(
          'Error no controlado en Defects.',
          statusCode: statusCode,
          apiError: apiError,
        );
    }
  }
}
