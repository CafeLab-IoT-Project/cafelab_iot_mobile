import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/api_message_error.dart'; 
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/environment_threshold.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/monitoring_alert.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/telemetry_record.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MonitoringApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiMessageError? apiError;

  const MonitoringApiException(this.message, {this.statusCode, this.apiError});

  String get displayMessage => apiError?.message ?? message;

  @override
  String toString() =>
      statusCode == null ? displayMessage : '$displayMessage (HTTP $statusCode)';
}

class MonitoringApiService {
  MonitoringApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _monitoringUri => Uri.parse('${ApiConfig.baseUrl}${ApiConfig.monitoringBasePath}');
  Uri get _telemetryUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/telemetry-records');

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const MonitoringApiException(
        'No hay token de sesión. Inicia sesión antes de usar Monitoreo Ambiental.',
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  // 1. POST: Registrar un umbral ambiental inicial
  Future<EnvironmentThreshold> createThreshold(EnvironmentThreshold threshold) async {
    final headers = await _authHeaders();
    final payload = jsonEncode(threshold.toJson());
    return _requestOneThreshold(
      method: 'POST',
      uri: _monitoringUri,
      headers: headers,
      expectedCode: HttpStatus.created,
      body: payload,
    );
  }

  // 2. GET: Obtener umbrales de un lote por ID
  Future<EnvironmentThreshold> getThresholdByLotId(int coffeeLotId) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_monitoringUri/coffee-lot/$coffeeLotId');
    return _requestOneThreshold(
      method: 'GET',
      uri: uri,
      headers: headers,
      expectedCode: HttpStatus.ok,
    );
  }

  // 3. PUT: Actualizar umbrales existentes
  Future<EnvironmentThreshold> updateThreshold(int coffeeLotId, EnvironmentThreshold threshold) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_monitoringUri/coffee-lot/$coffeeLotId');
    final payload = jsonEncode(threshold.toJson());
    return _requestOneThreshold(
      method: 'PUT',
      uri: uri,
      headers: headers,
      expectedCode: HttpStatus.ok,
      body: payload,
    );
  }

  // 4. GET: Obtener historial de telemetría por ID de lote
  Future<List<TelemetryRecord>> getTelemetryByLotId(int coffeeLotId) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('$_telemetryUri/coffee-lot/$coffeeLotId');
    
    final response = await _send(method: 'GET', uri: uri, headers: headers);
    if (response.statusCode == HttpStatus.ok) {
      if (response.body.trim().isEmpty) return [];
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(TelemetryRecord.fromJson)
            .toList();
      }
      return [];
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  // 5. GET: Obtener alertas de un lote específico
  Future<List<dynamic>> getAlertsByLotId(int lotId) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/monitoring-alerts/coffee-lot/$lotId');
    
    final response = await _send(
      method: 'GET', 
      uri: uri, 
      headers: headers
    );
    
    if (response.statusCode == HttpStatus.ok) {
      // Retornamos el JSON decodificado como lista cruda
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  // 6. PATCH: Marcar alerta como leída
  Future<void> markAlertAsRead(int alertId) async {
    final headers = await _authHeaders();
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/v1/monitoring-alerts/$alertId/read');
    
    final response = await _send(
      method: 'PATCH', 
      uri: uri, 
      headers: headers
    );
    
    if (response.statusCode != HttpStatus.noContent && response.statusCode != HttpStatus.ok) {
      throw _mapHttpError(response.statusCode, response.body);
    }
  }

  Future<EnvironmentThreshold> _requestOneThreshold({
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
      return EnvironmentThreshold.fromJson(decoded);
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    debugPrint('[MonitoringApiService] $method $uri');
    if (body != null) {
      debugPrint('[MonitoringApiService] body: $body');
    }

    try {
      final response = switch (method) {
        'POST' => await _client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 15)),
        'GET' => await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
        'PUT' => await _client
            .put(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 15)),
        'PATCH' => await _client
            .patch(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 15)),
        _ => throw const MonitoringApiException('Método HTTP no soportado'),
      };

      debugPrint('[MonitoringApiService] status: ${response.statusCode}');
      return response;
    } on SocketException {
      throw const MonitoringApiException(
        'No se pudo conectar con el servidor IoT. Revisa tu conexión de red.',
      );
    } on TimeoutException {
      throw const MonitoringApiException(
        'Tiempo de espera agotado al consultar el monitoreo IoT.',
      );
    }
  }

  MonitoringApiException _mapHttpError(int statusCode, String responseBody) {
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
        return MonitoringApiException(
          'Sesión expirada o perfil no válido para monitoreo ambiental.',
          statusCode: statusCode,
          apiError: apiError,
        );
      case HttpStatus.badRequest:
        return MonitoringApiException(
          'Rangos de umbrales inválidos o error de sintaxis.',
          statusCode: statusCode,
          apiError: apiError,
        );
      case HttpStatus.notFound:
        return MonitoringApiException(
          'Configuración ambiental o lote no encontrado.',
          statusCode: statusCode,
          apiError: apiError,
        );
      default:
        return MonitoringApiException(
          'Error inesperado en el Bounded Context de Monitoreo.',
          statusCode: statusCode,
          apiError: apiError,
        );
    }
  }
}