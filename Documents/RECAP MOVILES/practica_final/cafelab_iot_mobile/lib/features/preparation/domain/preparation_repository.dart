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

abstract class PreparationRepository {
  Future<Portfolio> createPortfolio(CreatePortfolioRequest request);
  Future<List<Portfolio>> listPortfolios();
  Future<Portfolio> getPortfolioById(int portfolioId);
  Future<Portfolio> updatePortfolio(int portfolioId, UpdatePortfolioRequest request);
  Future<MessageResponse> deletePortfolio(int portfolioId);

  Future<Recipe> createRecipe(CreateRecipeRequest request);
  Future<List<Recipe>> listRecipes();
  Future<Recipe> getRecipeById(int recipeId);
  Future<Recipe> updateRecipe(int recipeId, UpdateRecipeRequest request);
  Future<MessageResponse> deleteRecipe(int recipeId);

  Future<Ingredient> createIngredient(int recipeId, CreateIngredientRequest request);
  Future<List<Ingredient>> listIngredients(int recipeId);
  Future<Ingredient> updateIngredient(
    int recipeId,
    int ingredientId,
    UpdateIngredientRequest request,
  );
  Future<MessageResponse> deleteIngredient(int recipeId, int ingredientId);
}
