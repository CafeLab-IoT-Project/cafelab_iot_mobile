String grindCalibrationDateToWire(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime grindCalibrationDateFromWire(String raw) => DateTime.parse(raw);

class GrindCalibration {
  const GrindCalibration({
    required this.id,
    required this.userId,
    required this.name,
    required this.method,
    required this.equipment,
    required this.grindNumber,
    required this.aperture,
    required this.cupVolume,
    required this.finalVolume,
    required this.calibrationDate,
    this.comments,
    this.notes,
    this.sampleImage,
  });

  final int id;
  final int userId;
  final String name;
  final String method;
  final String equipment;
  final String grindNumber;
  final double aperture;
  final double cupVolume;
  final double finalVolume;
  final DateTime calibrationDate;
  final String? comments;
  final String? notes;
  final String? sampleImage;

  factory GrindCalibration.fromJson(Map<String, dynamic> json) {
    return GrindCalibration(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      method: json['method'] as String,
      equipment: json['equipment'] as String,
      grindNumber: json['grindNumber'] as String,
      aperture: (json['aperture'] as num).toDouble(),
      cupVolume: (json['cupVolume'] as num).toDouble(),
      finalVolume: (json['finalVolume'] as num).toDouble(),
      calibrationDate:
          grindCalibrationDateFromWire(json['calibrationDate'] as String),
      comments: json['comments'] as String?,
      notes: json['notes'] as String?,
      sampleImage: json['sampleImage'] as String?,
    );
  }
}
