import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';

class CreateSupplierRequestDto {
  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  const CreateSupplierRequestDto({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });

  factory CreateSupplierRequestDto.fromInput(CreateSupplierInput input) {
    return CreateSupplierRequestDto(
      name: input.name,
      email: input.email,
      phone: input.phone,
      location: input.location,
      specialties: input.specialties,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'location': location,
      'specialties': specialties,
    };
  }
}
