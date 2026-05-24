import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/defect_model.dart';

abstract class DefectsRepository {
  Future<DefectModel> createDefect(CreateDefectRequest request);
  Future<List<DefectModel>> getDefects();
  Future<DefectModel> getDefectById(int defectId);
}
