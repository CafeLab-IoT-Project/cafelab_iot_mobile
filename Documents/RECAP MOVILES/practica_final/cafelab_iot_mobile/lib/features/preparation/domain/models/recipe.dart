import 'package:cafelab_iot_mobile/features/preparation/domain/models/ingredient.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.extractionMethod,
    required this.extractionCategory,
    required this.ratio,
    required this.cuppingSessionId,
    required this.portfolioId,
    required this.preparationTime,
    required this.steps,
    required this.tips,
    required this.cupping,
    required this.grindSize,
    required this.createdAt,
    required this.ingredients,
  });

  final int id;
  final int userId;
  final String name;
  final String imageUrl;
  final String extractionMethod;
  final String extractionCategory;
  final String ratio;
  final int cuppingSessionId;
  final int portfolioId;
  final int preparationTime;
  final String steps;
  final String tips;
  final String cupping;
  final String grindSize;
  final String createdAt;
  final List<Ingredient> ingredients;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    final parsedIngredients = <Ingredient>[];
    if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item is Map<String, dynamic>) {
          parsedIngredients.add(Ingredient.fromJson(item));
        }
      }
    }
    return Recipe(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      extractionMethod: json['extractionMethod'] as String,
      extractionCategory: json['extractionCategory'] as String,
      ratio: json['ratio'] as String,
      cuppingSessionId: (json['cuppingSessionId'] as num).toInt(),
      portfolioId: (json['portfolioId'] as num).toInt(),
      preparationTime: (json['preparationTime'] as num).toInt(),
      steps: json['steps'] as String,
      tips: (json['tips'] as String?) ?? '',
      cupping: (json['cupping'] as String?) ?? '',
      grindSize: (json['grindSize'] as String?) ?? '-',
      createdAt: json['createdAt'] as String,
      ingredients: parsedIngredients,
    );
  }
}
