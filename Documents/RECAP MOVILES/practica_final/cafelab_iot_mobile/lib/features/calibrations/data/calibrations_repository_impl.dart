import 'package:cafelab_iot_mobile/features/calibrations/data/calibrations_api_service.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/calibrations_repository.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';

class CalibrationsRepositoryImpl implements CalibrationsRepository {
  CalibrationsRepositoryImpl({CalibrationsApiService? apiService})
      : _apiService = apiService ?? CalibrationsApiService();

  final CalibrationsApiService _apiService;

  @override
  Future<GrindCalibration> create(CreateGrindCalibrationRequest request) {
    return _apiService.create(request);
  }

  @override
  Future<List<GrindCalibration>> list() {
    return _apiService.list();
  }

  @override
  Future<GrindCalibration> getById(int id) {
    return _apiService.getById(id);
  }

  @override
  Future<GrindCalibration> update(int id, UpdateGrindCalibrationRequest request) {
    return _apiService.update(id, request);
  }
}
