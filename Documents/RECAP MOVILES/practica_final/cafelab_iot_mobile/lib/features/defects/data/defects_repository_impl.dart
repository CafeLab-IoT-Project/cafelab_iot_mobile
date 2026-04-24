import 'package:cafelab_iot_mobile/features/defects/data/defects_api_service.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/defects_repository.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/defect_model.dart';

class DefectsRepositoryImpl implements DefectsRepository {
  DefectsRepositoryImpl({DefectsApiService? apiService})
      : _apiService = apiService ?? DefectsApiService();

  final DefectsApiService _apiService;

  @override
  Future<DefectModel> createDefect(CreateDefectRequest request) {
    return _apiService.createDefect(request);
  }

  @override
  Future<DefectModel> getDefectById(int defectId) {
    return _apiService.getDefectById(defectId);
  }

  @override
  Future<List<DefectModel>> getDefects() {
    return _apiService.getDefects();
  }
}
