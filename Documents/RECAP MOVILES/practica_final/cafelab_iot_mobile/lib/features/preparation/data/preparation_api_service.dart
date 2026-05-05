import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/create_ingredient_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/create_portfolio_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/create_recipe_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/ingredient.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/message_response.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/portfolio.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/recipe.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/update_ingredient_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/update_portfolio_request.dart';
import 'package:cafelab_iot_mobile/features/preparation/domain/models/update_recipe_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PreparationApiService {
  PreparationApiService({http.Client? client, TokenStorageService? tokenStorage})
      : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final http.Client _client;
  final TokenStorageService _tokenStorage;

  Uri get _portfoliosUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/portfolios');
  Uri get _recipesUri => Uri.parse('${ApiConfig.baseUrl}/api/v1/recipes');

  Uri _ingredientsUri(int recipeId) =>
      Uri.parse('${_recipesUri.toString()}/$recipeId/ingredients');

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

  Future<Portfolio> createPortfolio(CreatePortfolioRequest request) async {
    final response = await _send(
      method: 'POST',
      uri: _portfoliosUri,
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return Portfolio.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Portfolios');
  }

  Future<List<Portfolio>> listPortfolios() async {
    final response = await _send(method: 'GET', uri: _portfoliosUri);
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body, Portfolio.fromJson);
    throw _mapError(response.statusCode, response.body, 'Error en Portfolios');
  }

  Future<Portfolio> getPortfolioById(int portfolioId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_portfoliosUri.toString()}/$portfolioId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return Portfolio.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Portfolios');
  }

  Future<Portfolio> updatePortfolio(int portfolioId, UpdatePortfolioRequest request) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_portfoliosUri.toString()}/$portfolioId'),
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return Portfolio.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Portfolios');
  }

  Future<MessageResponse> deletePortfolio(int portfolioId) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_portfoliosUri.toString()}/$portfolioId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return MessageResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Portfolios');
  }

  Future<Recipe> createRecipe(CreateRecipeRequest request) async {
    final response = await _send(
      method: 'POST',
      uri: _recipesUri,
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Recipes');
  }

  Future<List<Recipe>> listRecipes() async {
    final response = await _send(method: 'GET', uri: _recipesUri);
    if (response.statusCode == HttpStatus.ok) return _parseList(response.body, Recipe.fromJson);
    throw _mapError(response.statusCode, response.body, 'Error en Recipes');
  }

  Future<Recipe> getRecipeById(int recipeId) async {
    final response = await _send(
      method: 'GET',
      uri: Uri.parse('${_recipesUri.toString()}/$recipeId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Recipes');
  }

  Future<Recipe> updateRecipe(int recipeId, UpdateRecipeRequest request) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_recipesUri.toString()}/$recipeId'),
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return Recipe.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Recipes');
  }

  Future<MessageResponse> deleteRecipe(int recipeId) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_recipesUri.toString()}/$recipeId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return MessageResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Recipes');
  }

  Future<Ingredient> createIngredient(int recipeId, CreateIngredientRequest request) async {
    final response = await _send(
      method: 'POST',
      uri: _ingredientsUri(recipeId),
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.created) {
      return Ingredient.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Ingredients');
  }

  Future<List<Ingredient>> listIngredients(int recipeId) async {
    final response = await _send(method: 'GET', uri: _ingredientsUri(recipeId));
    if (response.statusCode == HttpStatus.ok) {
      return _parseList(response.body, Ingredient.fromJson);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Ingredients');
  }

  Future<Ingredient> updateIngredient(
    int recipeId,
    int ingredientId,
    UpdateIngredientRequest request,
  ) async {
    final response = await _send(
      method: 'PUT',
      uri: Uri.parse('${_ingredientsUri(recipeId).toString()}/$ingredientId'),
      body: jsonEncode(request.toJson()),
      includeContentType: true,
    );
    if (response.statusCode == HttpStatus.ok) {
      return Ingredient.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Ingredients');
  }

  Future<MessageResponse> deleteIngredient(int recipeId, int ingredientId) async {
    final response = await _send(
      method: 'DELETE',
      uri: Uri.parse('${_ingredientsUri(recipeId).toString()}/$ingredientId'),
    );
    if (response.statusCode == HttpStatus.ok) {
      return MessageResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }
    throw _mapError(response.statusCode, response.body, 'Error en Ingredients');
  }

  Future<http.Response> _send({
    required String method,
    required Uri uri,
    String? body,
    bool includeContentType = false,
  }) async {
    final headers = await _headers(includeContentType: includeContentType);
    debugPrint('[PreparationApiService] $method $uri');
    debugPrint(
      '[PreparationApiService] auth present: ${headers.containsKey(HttpHeaders.authorizationHeader)}',
    );
    if (body != null) debugPrint('[PreparationApiService] body: $body');

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

    debugPrint('[PreparationApiService] status: ${response.statusCode}');
    debugPrint('[PreparationApiService] response: ${response.body}');
    return response;
  }

  List<T> _parseList<T>(
    String body,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (body.trim().isEmpty) return [];
    final decoded = jsonDecode(body);
    if (decoded is! List) return [];
    return decoded.whereType<Map<String, dynamic>>().map(fromJson).toList();
  }

  ProductionApiException _mapError(int statusCode, String body, String fallbackMessage) {
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
      fallbackMessage,
      statusCode: statusCode,
      errorResponse: parsed,
      rawBody: body,
    );
  }
}
