import 'package:cafelab_iot_mobile/features/coffees/data/coffees_api_service.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/coffees_repository.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/coffee.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/create_coffee_request.dart';

class CoffeesRepositoryImpl implements CoffeesRepository {
  CoffeesRepositoryImpl({CoffeesApiService? apiService})
      : _apiService = apiService ?? CoffeesApiService();

  final CoffeesApiService _apiService;

  @override
  Future<Coffee> create(CreateCoffeeRequest request) {
    return _apiService.create(request);
  }

  @override
  Future<Coffee> getById(int id) {
    return _apiService.getById(id);
  }

  @override
  Future<List<Coffee>> getAll() {
    return _apiService.getAll();
  }
}
