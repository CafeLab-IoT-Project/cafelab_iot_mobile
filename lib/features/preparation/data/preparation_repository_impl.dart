import 'package:cafelab_iot_mobile/features/preparation/data/preparation_api_service.dart';
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
import 'package:cafelab_iot_mobile/features/preparation/domain/preparation_repository.dart';

class PreparationRepositoryImpl implements PreparationRepository {
  PreparationRepositoryImpl({PreparationApiService? apiService})
      : _apiService = apiService ?? PreparationApiService();

  final PreparationApiService _apiService;

  @override
  Future<Portfolio> createPortfolio(CreatePortfolioRequest request) {
    return _apiService.createPortfolio(request);
  }

  @override
  Future<List<Portfolio>> listPortfolios() {
    return _apiService.listPortfolios();
  }

  @override
  Future<Portfolio> getPortfolioById(int portfolioId) {
    return _apiService.getPortfolioById(portfolioId);
  }

  @override
  Future<Portfolio> updatePortfolio(int portfolioId, UpdatePortfolioRequest request) {
    return _apiService.updatePortfolio(portfolioId, request);
  }

  @override
  Future<MessageResponse> deletePortfolio(int portfolioId) {
    return _apiService.deletePortfolio(portfolioId);
  }

  @override
  Future<Recipe> createRecipe(CreateRecipeRequest request) {
    return _apiService.createRecipe(request);
  }

  @override
  Future<List<Recipe>> listRecipes() {
    return _apiService.listRecipes();
  }

  @override
  Future<Recipe> getRecipeById(int recipeId) {
    return _apiService.getRecipeById(recipeId);
  }

  @override
  Future<Recipe> updateRecipe(int recipeId, UpdateRecipeRequest request) {
    return _apiService.updateRecipe(recipeId, request);
  }

  @override
  Future<MessageResponse> deleteRecipe(int recipeId) {
    return _apiService.deleteRecipe(recipeId);
  }

  @override
  Future<Ingredient> createIngredient(int recipeId, CreateIngredientRequest request) {
    return _apiService.createIngredient(recipeId, request);
  }

  @override
  Future<List<Ingredient>> listIngredients(int recipeId) {
    return _apiService.listIngredients(recipeId);
  }

  @override
  Future<Ingredient> updateIngredient(
    int recipeId,
    int ingredientId,
    UpdateIngredientRequest request,
  ) {
    return _apiService.updateIngredient(recipeId, ingredientId, request);
  }

  @override
  Future<MessageResponse> deleteIngredient(int recipeId, int ingredientId) {
    return _apiService.deleteIngredient(recipeId, ingredientId);
  }
}
