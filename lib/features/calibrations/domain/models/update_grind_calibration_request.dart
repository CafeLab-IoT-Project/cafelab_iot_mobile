import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';

class UpdateGrindCalibrationRequest {
  const UpdateGrindCalibrationRequest({
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

  Map<String, dynamic> toJson() => {
        'name': name,
        'method': method,
        'equipment': equipment,
        'grindNumber': grindNumber,
        'aperture': aperture,
        'cupVolume': cupVolume,
        'finalVolume': finalVolume,
        'calibrationDate': grindCalibrationDateToWire(calibrationDate),
        'comments': comments,
        'notes': notes,
        'sampleImage': sampleImage,
      };
}
