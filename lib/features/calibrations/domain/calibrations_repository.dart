import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';

abstract class CalibrationsRepository {
  Future<GrindCalibration> create(CreateGrindCalibrationRequest request);

  Future<List<GrindCalibration>> list();

  Future<GrindCalibration> getById(int id);

  Future<GrindCalibration> update(int id, UpdateGrindCalibrationRequest request);
}
