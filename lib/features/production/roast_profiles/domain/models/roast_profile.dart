class RoastProfile {
  final int id;
  final int userId;
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int coffeeLotId;
  final bool isFavorite;

  const RoastProfile({
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
}
