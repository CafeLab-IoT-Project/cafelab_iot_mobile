import 'package:cafelab_iot_mobile/features/production/suppliers/data/dto/supplier_response_dto.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';

class SupplierMapper {
  static Supplier toDomain(SupplierResponseDto dto) {
    return Supplier(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      email: dto.email,
      phone: dto.phone,
      location: dto.location,
      specialties: dto.specialties,
    );
  }
}
