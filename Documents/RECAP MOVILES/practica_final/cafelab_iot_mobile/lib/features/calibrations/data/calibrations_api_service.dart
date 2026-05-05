import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CalibrationsApiService {
  CalibrationsApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _baseUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/calibrations');

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

  Future<GrindCalibration> create(CreateGrindCalibrationRequest dto) async {
    final response = await _send(
      method: 'POST',
      uri: _baseUri,
      body: jsonEncode(dto.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return GrindCalibration.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<GrindCalibration>> list() async {
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

  Future<GrindCalibration> getById(int calibrationId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/$calibrationId'),
      includeContentType: false,
    );
    if (response.statusCode == HttpStatus.ok) {
      return GrindCalibration.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<GrindCalibration> update(
    int calibrationId,
    UpdateGrindCalibrationRequest dto,
  ) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_baseUri.toString()}/$calibrationId'),
      body: jsonEncode(dto.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return GrindCalibration.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
    required bool includeContentType,
  }) async {
    final headers = await _headers(includeContentType: includeContentType);
    debugPrint('[CalibrationsApiService] $method $uri');
    debugPrint(
      '[CalibrationsApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[CalibrationsApiService] body: $body');

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
      _ => throw const ProductionApiException('Metodo no soportado'),
    };

    debugPrint('[CalibrationsApiService] status: ${response.statusCode}');
    debugPrint('[CalibrationsApiService] response: ${response.body}');
    return response;
  }

  List<GrindCalibration> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(GrindCalibration.fromJson)
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
      'Error en Calibrations',
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
