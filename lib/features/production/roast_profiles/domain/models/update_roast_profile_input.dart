class UpdateRoastProfileInput {
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int lot;
  final bool isFavorite;

  const UpdateRoastProfileInput({
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.lot,
    required this.isFavorite,
  });
}
