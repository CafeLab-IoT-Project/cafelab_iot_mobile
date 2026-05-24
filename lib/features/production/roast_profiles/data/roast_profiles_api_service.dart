import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/create_roast_profile_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/roast_profile_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/data/dto/update_roast_profile_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RoastProfilesApiService {
  RoastProfilesApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _baseUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/roast-profile');

  Future<Map<String, String>> _authHeaders() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw const ProductionApiException(
        'No hay token de sesion disponible.',
        statusCode: 401,
      );
    }
    return {
      HttpHeaders.authorizationHeader: 'Bearer $token',
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<RoastProfileResponseDto> create(CreateRoastProfileRequestDto dto) async {
    final response = await _send(
      method: 'POST',
      uri: _baseUri,
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == HttpStatus.created) {
      return RoastProfileResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<RoastProfileResponseDto>> getAll() async {
    final response = await _send(method: 'GET', uri: _baseUri);
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<RoastProfileResponseDto>> getByUserId(int userId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/profile/$userId'),
    );
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<RoastProfileResponseDto>> getByCoffeeLotId(int coffeeLotId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/lot/$coffeeLotId'),
    );
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<RoastProfileResponseDto> getById(int id) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/$id'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return RoastProfileResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<RoastProfileResponseDto> update(int id, UpdateRoastProfileRequestDto dto) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_baseUri.toString()}/$id'),
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == HttpStatus.ok) {
      return RoastProfileResponseDto.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<String> delete(int id) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_baseUri.toString()}/$id'),
    );
    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return (decoded['message'] as String?) ?? 'Eliminado exitosamente';
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
  }) async {
    final headers = await _authHeaders();
    debugPrint('[RoastProfilesApiService] $method $uri');
    debugPrint(
      '[RoastProfilesApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[RoastProfilesApiService] body: $body');
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
    debugPrint('[RoastProfilesApiService] status: ${response.statusCode}');
    debugPrint('[RoastProfilesApiService] response: ${response.body}');
    return response;
  }

  List<RoastProfileResponseDto> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(RoastProfileResponseDto.fromJson)
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
      'Error en Roast Profiles',
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
