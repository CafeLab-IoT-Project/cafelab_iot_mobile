class CreateRoastProfileInput {
  final String name;
  final String type;
  final int duration;
  final double tempStart;
  final double tempEnd;
  final int lot;
  final bool? isFavorite;

  const CreateRoastProfileInput({
    required this.name,
    required this.type,
    required this.duration,
    required this.tempStart,
    required this.tempEnd,
    required this.lot,
    this.isFavorite,
  });
}
