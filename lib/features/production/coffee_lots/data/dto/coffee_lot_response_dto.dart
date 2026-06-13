class CoffeeLotResponseDto {
  final int id;
  final int userId;
  final int supplierId;
  final String lotName;
  final String coffeeType;
  final String processingMethod;
  final int altitude;
  final double weight;
  final String origin;
  final String status;
  final List<String> certifications;

  const CoffeeLotResponseDto({
    required this.id,
    required this.userId,
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

  factory CoffeeLotResponseDto.fromJson(Map<String, dynamic> json) {
    final certs = <String>[];
    final rawCerts = json['certifications'];
    if (rawCerts is List) {
      for (final item in rawCerts) {
        if (item is String) certs.add(item);
      }
    }
    return CoffeeLotResponseDto(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      supplierId: (json['supplierId'] as num).toInt(),
      lotName: json['lotName'] as String,
      coffeeType: json['coffeeType'] as String,
      processingMethod: json['processingMethod'] as String,
      altitude: (json['altitude'] as num).toInt(),
      weight: (json['weight'] as num).toDouble(),
      origin: json['origin'] as String,
      status: json['status'] as String,
      certifications: certs,
    );
  }
}
