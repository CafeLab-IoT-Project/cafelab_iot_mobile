class CreateIngredientRequest {
  const CreateIngredientRequest({
    required this.recipeId,
    required this.name,
    required this.amount,
    required this.unit,
  });

  final int recipeId;
  final String name;
  final double amount;
  final String unit;

  Map<String, dynamic> toJson() => {
        'recipeId': recipeId,
        'name': name,
        'amount': amount,
        'unit': unit,
      };
}
