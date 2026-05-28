import 'package:cafelab_iot_mobile/features/cost_management/domain/models/create_production_cost_record_input.dart';

class CreateProductionCostRecordRequestDto {
  const CreateProductionCostRecordRequestDto({
    required this.coffeeLotId,
    required this.currency,
    required this.totalKg,
    required this.marginPercent,
    required this.rawMaterialsCost,
    required this.laborCost,
    required this.transportCost,
    required this.storageCost,
    required this.processingCost,
    required this.otherIndirectCosts,
  });

  final int coffeeLotId;
  final String currency;
  final double totalKg;
  final double marginPercent;
  final double rawMaterialsCost;
  final double laborCost;
  final double transportCost;
  final double storageCost;
  final double processingCost;
  final double otherIndirectCosts;

  factory CreateProductionCostRecordRequestDto.fromInput(
    CreateProductionCostRecordInput input,
  ) {
    return CreateProductionCostRecordRequestDto(
      coffeeLotId: input.coffeeLotId,
      currency: input.currency,
      totalKg: input.totalKg,
      marginPercent: input.marginPercent,
      rawMaterialsCost: input.rawMaterialsCost,
      laborCost: input.laborCost,
      transportCost: input.transportCost,
      storageCost: input.storageCost,
      processingCost: input.processingCost,
      otherIndirectCosts: input.otherIndirectCosts,
    );
  }

  Map<String, dynamic> toJson() => {
        'coffeeLotId': coffeeLotId,
        'currency': currency,
        'totalKg': totalKg,
        'marginPercent': marginPercent,
        'rawMaterialsCost': rawMaterialsCost,
        'laborCost': laborCost,
        'transportCost': transportCost,
        'storageCost': storageCost,
        'processingCost': processingCost,
        'otherIndirectCosts': otherIndirectCosts,
      };
}
