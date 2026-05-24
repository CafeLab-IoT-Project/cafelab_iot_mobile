import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/coffee_lot_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';

class CoffeeLotMapper {
  static CoffeeLot toDomain(CoffeeLotResponseDto dto) {
    return CoffeeLot(
      id: dto.id,
      userId: dto.userId,
      supplierId: dto.supplierId,
      lotName: dto.lotName,
      coffeeType: dto.coffeeType,
      processingMethod: dto.processingMethod,
      altitude: dto.altitude,
      weight: dto.weight,
      origin: dto.origin,
      status: dto.status,
      certifications: dto.certifications,
    );
  }
}
