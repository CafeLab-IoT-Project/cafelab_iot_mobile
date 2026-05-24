import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/create_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/update_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CuppingSessionsApiService {
  CuppingSessionsApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _baseUri =>
      Uri.parse('${ApiConfig.baseUrl}/api/v1/cupping-sessions');

  Future<Map<String, String>> _headers({bool includeContentType = true}) async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const ProductionApiException(
        'No hay token de sesion disponible.',
        statusCode: 401,
      );
    }
    final headers = <String, String>{
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.acceptHeader: 'application/json',
    };
    if (includeContentType) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }
    return headers;
  }

  Future<CuppingSession> create(CreateCuppingSessionRequest dto) async {
    final response = await _send(
      method: 'POST',
      uri: _baseUri,
      body: jsonEncode(dto.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return CuppingSession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<CuppingSession>> list() async {
    final response = await _send(
      method: 'GET',
      uri: _baseUri,
      includeContentType: false,
    );
    if (response.statusCode == HttpStatus.ok) {
      return _parseList(response.body);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<CuppingSession> getById(int sessionId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/$sessionId'),
      includeContentType: false,
    );
    if (response.statusCode == HttpStatus.ok) {
      return CuppingSession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<CuppingSession> update(
    int sessionId,
    UpdateCuppingSessionRequest dto,
  ) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_baseUri.toString()}/$sessionId'),
      body: jsonEncode(dto.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return CuppingSession.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<void> delete(int sessionId) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_baseUri.toString()}/$sessionId'),
      includeContentType: false,
    );
    if (response.statusCode == HttpStatus.noContent) return;
    throw _mapError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
    required bool includeContentType,
  }) async {
    final headers = await _headers(includeContentType: includeContentType);
    debugPrint('[CuppingSessionsApiService] $method $uri');
    debugPrint(
      '[CuppingSessionsApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[CuppingSessionsApiService] body: $body');

    final response = switch (method) {
      'POST' => await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20)),
      'GET' => await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20)),
      'PUT' => await _client
          .put(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20)),
      'DELETE' => await _client
          .delete(uri, headers: headers)
          .timeout(const Duration(seconds: 20)),
      _ => throw const ProductionApiException('Metodo no soportado'),
    };

    debugPrint('[CuppingSessionsApiService] status: ${response.statusCode}');
    if (response.statusCode != HttpStatus.noContent) {
      debugPrint('[CuppingSessionsApiService] response: ${response.body}');
    }
    return response;
  }

  List<CuppingSession> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CuppingSession.fromJson)
        .toList();
  }

  ProductionApiException _mapError(int statusCode, String body) {
    ApiErrorResponse? parsed;
    if (body.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          parsed = ApiErrorResponse.fromJson(decoded);
        }
      } catch (_) {}
    }
    return ProductionApiException(
      'Error en CuppingSessions',
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
