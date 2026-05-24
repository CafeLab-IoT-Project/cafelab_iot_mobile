import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/coffee.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/create_coffee_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CoffeesApiService {
  CoffeesApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _baseUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/coffees');

  Future<Map<String, String>> _headers() async {
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
      HttpHeaders.acceptHeader: 'application/json',
    };
  }

  Future<Coffee> create(CreateCoffeeRequest dto) async {
    final response = await _send(
      method: 'POST',
      uri: _baseUri,
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == HttpStatus.created) {
      return Coffee.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<Coffee> getById(int coffeeId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/$coffeeId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return Coffee.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<Coffee>> getAll() async {
    final response = await _send(method: 'GET', uri: _baseUri);
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
  }) async {
    final headers = await _headers();
    debugPrint('[CoffeesApiService] $method $uri');
    debugPrint(
      '[CoffeesApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[CoffeesApiService] body: $body');

    final response = switch (method) {
      'POST' => await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20)),
      'GET' => await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20)),
      _ => throw const ProductionApiException('Metodo no soportado'),
    };

    debugPrint('[CoffeesApiService] status: ${response.statusCode}');
    debugPrint('[CoffeesApiService] response: ${response.body}');
    return response;
  }

  List<Coffee> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Coffee.fromJson)
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
      'Error en Coffees',
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
