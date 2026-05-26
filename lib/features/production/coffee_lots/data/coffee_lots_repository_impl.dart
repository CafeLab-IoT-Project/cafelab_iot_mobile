import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_api_service.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/create_coffee_lot_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/dto/update_coffee_lot_request_dto.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/mappers/coffee_lot_mapper.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';

class CoffeeLotsRepositoryImpl implements CoffeeLotsRepository {
  CoffeeLotsRepositoryImpl({CoffeeLotsApiService? apiService})
    : _apiService = apiService ?? CoffeeLotsApiService();

  final CoffeeLotsApiService _apiService;

  @override
  Future<CoffeeLot> create(CreateCoffeeLotInput input) async {
    final dto = CreateCoffeeLotRequestDto.fromInput(input);
    final result = await _apiService.create(dto);
    return CoffeeLotMapper.toDomain(result);
  }

  @override
  Future<String> delete(int coffeeLotId) => _apiService.delete(coffeeLotId);

  @override
  Future<List<CoffeeLot>> getAll() async {
    final list = await _apiService.getAll();
    return list.map(CoffeeLotMapper.toDomain).toList();
  }

  @override
  Future<CoffeeLot> update(int coffeeLotId, UpdateCoffeeLotInput input) async {
    final dto = UpdateCoffeeLotRequestDto.fromInput(input);
    final result = await _apiService.update(coffeeLotId, dto);
    return CoffeeLotMapper.toDomain(result);
  }
}
