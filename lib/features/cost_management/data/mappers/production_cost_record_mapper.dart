import 'package:cafelab_iot_mobile/features/cost_management/data/dto/production_cost_record_response_dto.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record_status.dart';

abstract final class ProductionCostRecordMapper {
  static ProductionCostRecord toDomain(ProductionCostRecordResponseDto dto) {
    return ProductionCostRecord(
      id: dto.id,
      userId: dto.userId,
      coffeeLotId: dto.coffeeLotId,
      lotName: dto.lotName,
      coffeeType: dto.coffeeType,
      currency: dto.currency,
      totalKg: dto.totalKg,
      marginPercent: dto.marginPercent,
      rawMaterialsCost: dto.rawMaterialsCost,
      laborCost: dto.laborCost,
      transportCost: dto.transportCost,
      storageCost: dto.storageCost,
      processingCost: dto.processingCost,
      otherIndirectCosts: dto.otherIndirectCosts,
      totalDirectCost: dto.totalDirectCost,
      totalIndirectCost: dto.totalIndirectCost,
      totalCost: dto.totalCost,
      costPerKg: dto.costPerKg,
      suggestedPrice: dto.suggestedPrice,
      potentialMargin: dto.potentialMargin,
      status: ProductionCostRecordStatusX.fromApi(dto.status),
      reason: dto.reason,
      createdAt: _parseDate(dto.createdAt),
      updatedAt: _parseDate(dto.updatedAt),
    );
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw);
  }
}
