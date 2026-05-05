import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/message_response.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/update_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ManagementApiService {
  ManagementApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _baseUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/inventory-entries');

  Future<Map<String, String>> _headers({bool includeContentType = false}) async {
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

  Future<InventoryEntry> createInventoryEntry(CreateInventoryEntryRequest request) async {
    final response = await _send(
      method: 'POST',
      uri: _baseUri,
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return InventoryEntry.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<InventoryEntry>> listInventoryEntries() async {
    final response = await _send(method: 'GET', uri: _baseUri);
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<InventoryEntry>> listInventoryEntriesByProfile(int userId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/profile/$userId'),
    );
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<List<InventoryEntry>> listInventoryEntriesByCoffeeLot(int coffeeLotId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/coffee-lot/$coffeeLotId'),
    );
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body);
    throw _mapError(response.statusCode, response.body);
  }

  Future<InventoryEntry> getInventoryEntryById(int inventoryEntryId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_baseUri.toString()}/$inventoryEntryId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return InventoryEntry.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<InventoryEntry> updateInventoryEntry(
    int inventoryEntryId,
    UpdateInventoryEntryRequest request,
  ) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_baseUri.toString()}/$inventoryEntryId'),
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return InventoryEntry.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<MessageResponse> deleteInventoryEntry(int inventoryEntryId) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_baseUri.toString()}/$inventoryEntryId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return MessageResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
    bool includeContentType = false,
  }) async {
    final headers = await _headers(includeContentType: includeContentType);
    debugPrint('[ManagementApiService] $method $uri');
    debugPrint(
      '[ManagementApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[ManagementApiService] body: $body');

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

    debugPrint('[ManagementApiService] status: ${response.statusCode}');
    debugPrint('[ManagementApiService] response: ${response.body}');
    return response;
  }

  List<InventoryEntry> _parseList(String body) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded.whereType<Map<String, dynamic>>().map(InventoryEntry.fromJson).toList();
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
      'Error en InventoryEntries',
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
