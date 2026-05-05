import 'package:cafelab_iot_mobile/features/coffees/domain/models/coffee.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/create_coffee_request.dart';

abstract class CoffeesRepository {
  Future<Coffee> create(CreateCoffeeRequest request);

  Future<Coffee> getById(int id);

  Future<List<Coffee>> getAll();
}
