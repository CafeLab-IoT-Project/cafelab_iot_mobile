class RoastProfileResponseDto {
  final int id;
  final int userId;
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int coffeeLotId;
  final bool isFavorite;

  const RoastProfileResponseDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.coffeeLotId,
    required this.isFavorite,
  });

  factory RoastProfileResponseDto.fromJson(Map<String, dynamic> json) {
    return RoastProfileResponseDto(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      duration: (json['duration'] as num).toInt(),
      tempStart: (json['tempStart'] as num).toDouble(),
      tempEnd: (json['tempEnd'] as num).toDouble(),
      coffeeLotId: (json['coffeeLotId'] as num).toInt(),
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }
}
