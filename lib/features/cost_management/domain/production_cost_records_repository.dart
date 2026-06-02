import 'package:cafelab_iot_mobile/features/cost_management/domain/models/create_production_cost_record_input.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';

abstract interface class ProductionCostRecordsRepository {
  Future<List<ProductionCostRecord>> getAll();

  Future<ProductionCostRecord> getById(int id);

  Future<ProductionCostRecord> create(CreateProductionCostRecordInput input);

  Future<ProductionCostRecord> annul(int id, {required String reason});
}
