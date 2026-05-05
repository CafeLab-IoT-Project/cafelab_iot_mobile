class CreateRecipeRequest {
  const CreateRecipeRequest({
    required this.name,
    required this.imageUrl,
    required this.extractionMethod,
    required this.extractionCategory,
    required this.ratio,
    required this.cuppingSessionId,
    required this.portfolioId,
    required this.preparationTime,
    required this.steps,
    this.tips,
    this.cupping,
    this.grindSize,
  });

  final String name;
  final String imageUrl;
  final String extractionMethod;
  final String extractionCategory;
  final String ratio;
  final int cuppingSessionId;
  final int portfolioId;
  final int preparationTime;
  final String steps;
  final String? tips;
  final String? cupping;
  final String? grindSize;

  Map<String, dynamic> toJson() => {
        'name': name,
        'imageUrl': imageUrl,
        'extractionMethod': extractionMethod,
        'extractionCategory': extractionCategory,
        'ratio': ratio,
        'cuppingSessionId': cuppingSessionId,
        'portfolioId': portfolioId,
        'preparationTime': preparationTime,
        'steps': steps,
        'tips': tips,
        'cupping': cupping,
        'grindSize': grindSize,
      };
}
