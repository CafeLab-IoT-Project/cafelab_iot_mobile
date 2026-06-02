class ProductionCostRecordResponseDto {
  const ProductionCostRecordResponseDto({
    required this.id,
    required this.userId,
    required this.coffeeLotId,
    required this.lotName,
    required this.coffeeType,
    required this.currency,
    required this.totalKg,
    required this.marginPercent,
    required this.rawMaterialsCost,
    required this.laborCost,
    required this.transportCost,
    required this.storageCost,
    required this.processingCost,
    required this.otherIndirectCosts,
    required this.totalDirectCost,
    required this.totalIndirectCost,
    required this.totalCost,
    required this.costPerKg,
    required this.suggestedPrice,
    required this.potentialMargin,
    required this.status,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int userId;
  final int coffeeLotId;
  final String lotName;
  final String coffeeType;
  final String currency;
  final double totalKg;
  final double marginPercent;
  final double rawMaterialsCost;
  final double laborCost;
  final double transportCost;
  final double storageCost;
  final double processingCost;
  final double otherIndirectCosts;
  final double totalDirectCost;
  final double totalIndirectCost;
  final double totalCost;
  final double costPerKg;
  final double suggestedPrice;
  final double potentialMargin;
  final String status;
  final String reason;
  final String? createdAt;
  final String? updatedAt;

  factory ProductionCostRecordResponseDto.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      return double.tryParse('$value') ?? 0;
    }

    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse('$value') ?? 0;
    }

    return ProductionCostRecordResponseDto(
      id: toInt(json['id']),
      userId: toInt(json['userId']),
      coffeeLotId: toInt(json['coffeeLotId']),
      lotName: '${json['lotName'] ?? ''}',
      coffeeType: '${json['coffeeType'] ?? ''}',
      currency: '${json['currency'] ?? 'PEN'}',
      totalKg: toDouble(json['totalKg']),
      marginPercent: toDouble(json['marginPercent']),
      rawMaterialsCost: toDouble(json['rawMaterialsCost']),
      laborCost: toDouble(json['laborCost']),
      transportCost: toDouble(json['transportCost']),
      storageCost: toDouble(json['storageCost']),
      processingCost: toDouble(json['processingCost']),
      otherIndirectCosts: toDouble(json['otherIndirectCosts']),
      totalDirectCost: toDouble(json['totalDirectCost']),
      totalIndirectCost: toDouble(json['totalIndirectCost']),
      totalCost: toDouble(json['totalCost']),
      costPerKg: toDouble(json['costPerKg']),
      suggestedPrice: toDouble(json['suggestedPrice']),
      potentialMargin: toDouble(json['potentialMargin']),
      status: '${json['status'] ?? 'registrado'}',
      reason: '${json['reason'] ?? 'registrado'}',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
