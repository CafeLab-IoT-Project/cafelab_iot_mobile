import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/create_supplier_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/message_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/supplier_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/update_supplier_request_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SuppliersApiService {
  SuppliersApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _baseUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/suppliers');

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
    };
  }

  Future<SupplierResponseDto> createSupplier(CreateSupplierRequestDto dto) async {
    final response = await _send(
      method: 'POST',
      uri: _baseUri,
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == HttpStatus.created) {
      return SupplierResponseDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<SupplierResponseDto>> getSuppliers() async {
    final response = await _send(method: 'GET', uri: _baseUri);
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<SupplierResponseDto>> getSuppliersByUserId(int userId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/profile/$userId'),
    );
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<SupplierResponseDto> getSupplierById(int supplierId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/$supplierId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return SupplierResponseDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<SupplierResponseDto> updateSupplier(
    int supplierId,
    UpdateSupplierRequestDto dto,
  ) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_baseUri.toString()}/$supplierId'),
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == HttpStatus.ok) {
      return SupplierResponseDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<MessageResponseDto> deleteSupplier(int supplierId) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_baseUri.toString()}/$supplierId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return MessageResponseDto.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
  }) async {
    final headers = await _headers();
    debugPrint('[SuppliersApiService] $method $uri');
    debugPrint(
      '[SuppliersApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[SuppliersApiService] body: $body');

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

    debugPrint('[SuppliersApiService] status: ${response.statusCode}');
    debugPrint('[SuppliersApiService] response: ${response.body}');
    return response;
  }

  List<SupplierResponseDto> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SupplierResponseDto.fromJson)
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
      'Error en Suppliers',
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
