import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/auth_http_headers.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/api_message_error.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/create_profile_request.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/update_profile_request.dart';
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
  ProfileApiService({
    http.Client? client,
    AuthHttpHeaders? authHeaders,
  })  : _client = client ?? http.Client(),
        _authHeaders = authHeaders ?? AuthHttpHeaders();

  final http.Client _client;
  final AuthHttpHeaders _authHeaders;

  Uri get _profilesUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/profiles');

  Future<bool> isEmailAvailable({
    required String email,
    int? excludeProfileId,
  }) async {
    final query = <String, String>{
      'email': email.trim(),
      if (excludeProfileId != null) 'excludeUserId': '$excludeProfileId',
    };
    final uri = _profilesUri.replace(
      path: '${_profilesUri.path}/check-email',
      queryParameters: query,
    );
    final response = await _send(
      method: 'GET',
      uri: uri,
      headers: await _authHeaders.jsonWithTokenIfPresent(),
    );
    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['available'] as bool? ?? false;
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<bool> isCafeteriaNameAvailable({
    required String cafeteriaName,
    int? excludeProfileId,
  }) async {
    final query = <String, String>{
      'cafeteriaName': cafeteriaName.trim(),
      if (excludeProfileId != null) 'excludeUserId': '$excludeProfileId',
    };
    final uri = _profilesUri.replace(
      path: '${_profilesUri.path}/check-cafeteria',
      queryParameters: query,
    );
    final response = await _send(
      method: 'GET',
      uri: uri,
      headers: await _authHeaders.jsonWithTokenIfPresent(),
    );
    if (response.statusCode == HttpStatus.ok) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return decoded['available'] as bool? ?? false;
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<ProfileModel> getProfileByEmail(String email) async {
    final uri = Uri.parse('${_profilesUri.toString()}?email=$email');
    final response = await _send(
      method: 'GET',
      uri: uri,
      headers: await _authHeaders.jsonWithTokenIfPresent(),
    );
    if (response.statusCode == HttpStatus.ok) {
      return ProfileModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<ProfileModel> updateProfile({
    required int profileId,
    required UpdateProfileRequest request,
    Map<String, String>? authHeaders,
  }) async {
    final headers = {
      ...await _authHeaders.jsonWithTokenIfPresent(),
      if (authHeaders != null) ...authHeaders,
    };
    final body = jsonEncode(request.toJson());
    final uri = Uri.parse('${_profilesUri.toString()}/$profileId');
    final response = await _send(
      method: 'PATCH',
      uri: uri,
      headers: headers,
      body: body,
    );
    if (response.statusCode == HttpStatus.ok) {
      return ProfileModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapHttpError(response.statusCode, response.body);
  }

  Future<ProfileModel> createProfile(CreateProfileRequest request) async {
    final body = jsonEncode(request.toJson());
    final response = await _send(
      method: 'POST',
      uri: _profilesUri,
      headers: await _authHeaders.jsonWithTokenIfPresent(),
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
        'PATCH' => await _client
            .patch(uri, headers: headers, body: body)
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
