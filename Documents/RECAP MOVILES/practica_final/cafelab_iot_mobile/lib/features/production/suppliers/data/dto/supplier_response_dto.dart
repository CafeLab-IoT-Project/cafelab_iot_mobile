class SupplierResponseDto {
  final int id;
  final int userId;
  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  const SupplierResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });

  factory SupplierResponseDto.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['specialties'];
    final specs = <String>[];
    if (rawSpecs is List) {
      for (final item in rawSpecs) {
        if (item is String) specs.add(item);
      }
    }
    return SupplierResponseDto(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      phone: (json['phone'] as num).toInt(),
      location: json['location'] as String,
      specialties: specs,
    );
  }
}
