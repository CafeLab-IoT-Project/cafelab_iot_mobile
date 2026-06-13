class Ingredient {
  const Ingredient({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.amount,
    required this.unit,
  });

  final int id;
  final int recipeId;
  final String name;
  final double amount;
  final String unit;

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id: (json['id'] as num).toInt(),
      recipeId: (json['recipeId'] as num).toInt(),
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}
