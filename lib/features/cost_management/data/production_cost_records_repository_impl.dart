import 'package:cafelab_iot_mobile/features/cost_management/data/dto/annul_production_cost_record_request_dto.dart';
import 'package:cafelab_iot_mobile/features/cost_management/data/dto/create_production_cost_record_request_dto.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/create_production_cost_record_input.dart';
import 'package:cafelab_iot_mobile/features/cost_management/data/mappers/production_cost_record_mapper.dart';
import 'package:cafelab_iot_mobile/features/cost_management/data/production_cost_records_api_service.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/production_cost_records_repository.dart';

class ProductionCostRecordsRepositoryImpl
    implements ProductionCostRecordsRepository {
  ProductionCostRecordsRepositoryImpl({ProductionCostRecordsApiService? apiService})
      : _apiService = apiService ?? ProductionCostRecordsApiService();

  final ProductionCostRecordsApiService _apiService;

  @override
  Future<List<ProductionCostRecord>> getAll() async {
    final list = await _apiService.getAll();
    return list.map(ProductionCostRecordMapper.toDomain).toList();
  }

  @override
  Future<ProductionCostRecord> getById(int id) async {
    final dto = await _apiService.getById(id);
    return ProductionCostRecordMapper.toDomain(dto);
  }

  @override
  Future<ProductionCostRecord> create(CreateProductionCostRecordInput input) async {
    final dto = CreateProductionCostRecordRequestDto.fromInput(input);
    final result = await _apiService.create(dto);
    return ProductionCostRecordMapper.toDomain(result);
  }

  @override
  Future<ProductionCostRecord> annul(int id, {required String reason}) async {
    final dto = await _apiService.annul(
      id,
      AnnulProductionCostRecordRequestDto(reason: reason),
    );
    return ProductionCostRecordMapper.toDomain(dto);
  }
}
