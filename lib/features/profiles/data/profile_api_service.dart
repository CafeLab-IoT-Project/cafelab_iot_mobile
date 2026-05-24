import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/api_message_error.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/create_profile_request.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ProfileApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiMessageError? apiError;

  const ProfileApiException(this.message, {this.statusCode, this.apiError});

  String get displayMessage => apiError?.message ?? message;

  @override
  String toString() =>
      statusCode == null ? displayMessage : '$displayMessage (HTTP $statusCode)';
}

class ProfileApiService {
  ProfileApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Uri get _profilesUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/profiles');

  Map<String, String> _publicHeaders() {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
  }

  Future<ProfileModel> getProfileByEmail(String email) async {
    final headers = _publicHeaders();
    final uri = Uri.parse('${_profilesUri.toString()}?email=$email');
    final response = await _send(method: 'GET', uri: uri, headers: headers);
    if (response.statusCode == HttpStatus.ok) {
      return ProfileModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<ProfileModel> createProfile(CreateProfileRequest request) async {
    final headers = _publicHeaders();
    final body = jsonEncode(request.toJson());
    final response = await _send(
      method: 'POST',
      uri: _profilesUri,
      headers: headers,
      body: body,
    );
    if (response.statusCode == HttpStatus.created) {
      return ProfileModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    required Map<String, String> headers,
    String? body,
  }) async {
    debugPrint('[ProfileApiService] $method $uri');
    debugPrint(
      '[ProfileApiService] Authorization present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[ProfileApiService] body: $body');
    try {
      final response = switch (method) {
        'GET' => await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15)),
        'POST' => await _client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 15)),
        _ => throw const ProfileApiException('Metodo HTTP no soportado'),
      };
      debugPrint('[ProfileApiService] status: ${response.statusCode}');
      debugPrint('[ProfileApiService] response: ${response.body}');
      return response;
    } on SocketException {
      throw const ProfileApiException(
        'No se pudo conectar al backend de profiles.',
      );
    } on TimeoutException {
      throw const ProfileApiException('Timeout consumiendo profiles.');
    }
  }

  ProfileApiException _mapHttpError(int statusCode, String responseBody) {
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
        return ProfileApiException(
          'Sesion invalida o perfil no disponible. Reintenta login.',
          statusCode: statusCode,
          apiError: apiError,
        );
      case HttpStatus.notFound:
        return ProfileApiException(
          'Perfil no encontrado.',
          statusCode: statusCode,
          apiError: apiError,
        );
      case HttpStatus.badRequest:
        return ProfileApiException(
          'Error de validacion creando perfil.',
          statusCode: statusCode,
          apiError: apiError,
        );
      default:
        return ProfileApiException(
          'Error no controlado en profiles.',
          statusCode: statusCode,
          apiError: apiError,
        );
    }
  }
}
