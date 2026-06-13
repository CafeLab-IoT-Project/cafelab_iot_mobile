class CreateDefectRequest {
  final String coffeeDisplayName;
  final String? coffeeRegion;
  final String? coffeeVariety;
  final double? coffeeTotalWeight;
  final String name;
  final String defectType;
  final double defectWeight;
  final double percentage;
  final String probableCause;
  final String suggestedSolution;

  const CreateDefectRequest({
    required this.coffeeDisplayName,
    this.coffeeRegion,
    this.coffeeVariety,
    this.coffeeTotalWeight,
    required this.name,
    required this.defectType,
    required this.defectWeight,
    required this.percentage,
    required this.probableCause,
    required this.suggestedSolution,
  });

  Map<String, dynamic> toJson() {
    return {
      'coffeeDisplayName': coffeeDisplayName,
      if (coffeeRegion != null && coffeeRegion!.trim().isNotEmpty)
        'coffeeRegion': coffeeRegion,
      if (coffeeVariety != null && coffeeVariety!.trim().isNotEmpty)
        'coffeeVariety': coffeeVariety,
      if (coffeeTotalWeight != null) 'coffeeTotalWeight': coffeeTotalWeight,
      'name': name,
      'defectType': defectType,
      'defectWeight': defectWeight,
      'percentage': percentage,
      'probableCause': probableCause,
      'suggestedSolution': suggestedSolution,
    };
  }
}
