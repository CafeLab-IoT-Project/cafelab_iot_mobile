import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';

class CreateCoffeeLotRequestDto {
  final int supplierId;
  final String lotName;
  final String coffeeType;
  final String processingMethod;
  final int altitude;
  final double weight;
  final String origin;
  final String status;
  final List<String> certifications;

  const CreateCoffeeLotRequestDto({
    required this.supplierId,
    required this.lotName,
    required this.coffeeType,
    required this.processingMethod,
    required this.altitude,
    required this.weight,
    required this.origin,
    required this.status,
    required this.certifications,
  });

  factory CreateCoffeeLotRequestDto.fromInput(CreateCoffeeLotInput input) {
    return CreateCoffeeLotRequestDto(
      supplierId: input.supplierId,
      lotName: input.lotName,
      coffeeType: input.coffeeType,
      processingMethod: input.processingMethod,
      altitude: input.altitude,
      weight: input.weight,
      origin: input.origin,
      status: input.status,
      certifications: input.certifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplier_id': supplierId,
      'lot_name': lotName,
      'coffee_type': coffeeType,
      'processing_method': processingMethod,
      'altitude': altitude,
      'weight': weight,
      'origin': origin,
      'status': status,
      'certifications': certifications,
    };
  }
}
