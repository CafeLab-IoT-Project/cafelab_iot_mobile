import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record_status.dart';

class ProductionCostRecord {
  const ProductionCostRecord({
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
  final ProductionCostRecordStatus status;
  final String reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isAnnulled => status == ProductionCostRecordStatus.anulado;

  String get currencySymbol => currency.toUpperCase() == 'USD' ? r'$' : 'S/.';
}
