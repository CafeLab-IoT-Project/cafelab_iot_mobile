import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';

abstract class CoffeeLotsRepository {
  Future<CoffeeLot> create(CreateCoffeeLotInput input);
  Future<List<CoffeeLot>> getAll();
  Future<List<CoffeeLot>> getByUserId(int userId);
  Future<List<CoffeeLot>> getBySupplierId(int supplierId);
  Future<CoffeeLot> getById(int coffeeLotId);
  Future<CoffeeLot> update(int coffeeLotId, UpdateCoffeeLotInput input);
  Future<String> delete(int coffeeLotId);
}
