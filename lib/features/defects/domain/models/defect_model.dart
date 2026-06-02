import 'dart:convert';

class DefectModel {
  final int id;
  final int? userId;
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

  const DefectModel({
    required this.id,
    this.userId,
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

  factory DefectModel.fromJson(Map<String, dynamic> json) {
    return DefectModel(
      id: (json['id'] as num?)?.toInt() ?? -1,
      userId: (json['userId'] as num?)?.toInt(),
      coffeeDisplayName: (json['coffeeDisplayName'] as String?)?.trim() ?? '',
      coffeeRegion: _trimOrNull(json['coffeeRegion'] as String?),
      coffeeVariety: _trimOrNull(json['coffeeVariety'] as String?),
      coffeeTotalWeight: _parseDouble(json['coffeeTotalWeight']),
      name: (json['name'] as String?)?.trim() ?? '',
      defectType: (json['defectType'] as String?)?.trim() ?? '',
      defectWeight: _parseDouble(json['defectWeight']) ?? 0,
      percentage: _parseDouble(json['percentage']) ?? 0,
      probableCause: (json['probableCause'] as String?)?.trim() ?? '',
      suggestedSolution: (json['suggestedSolution'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'coffeeDisplayName': coffeeDisplayName,
      if (coffeeRegion != null) 'coffeeRegion': coffeeRegion,
      if (coffeeVariety != null) 'coffeeVariety': coffeeVariety,
      if (coffeeTotalWeight != null) 'coffeeTotalWeight': coffeeTotalWeight,
      'name': name,
      'defectType': defectType,
      'defectWeight': defectWeight,
      'percentage': percentage,
      'probableCause': probableCause,
      'suggestedSolution': suggestedSolution,
    };
  }

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  static String? _trimOrNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
