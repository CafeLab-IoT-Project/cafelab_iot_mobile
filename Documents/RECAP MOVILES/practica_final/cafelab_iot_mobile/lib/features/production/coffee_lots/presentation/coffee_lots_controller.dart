import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';

class CoffeeLotsController extends ChangeNotifier {
  CoffeeLotsController({CoffeeLotsRepository? repository})
      : _repository = repository ?? CoffeeLotsRepositoryImpl();

  final CoffeeLotsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  String? lastActionMessage;
  List<CoffeeLot> items = [];
  CoffeeLot? selected;

  Future<void> loadAll() async {
    await _run(() async {
      items = await _repository.getAll();
      lastActionMessage = 'Lotes cargados';
    });
  }

  Future<void> filterByUserId(int userId) async {
    await _run(() async {
      items = await _repository.getByUserId(userId);
      lastActionMessage = 'Filtrado por userId=$userId';
    });
  }

  Future<void> filterBySupplierId(int supplierId) async {
    await _run(() async {
      items = await _repository.getBySupplierId(supplierId);
      lastActionMessage = 'Filtrado por supplierId=$supplierId';
    });
  }

  Future<void> getById(int id) async {
    await _run(() async {
      selected = await _repository.getById(id);
      lastActionMessage = 'Detalle cargado para id=$id';
    });
  }

  Future<void> create(CreateCoffeeLotInput input) async {
    await _run(() async {
      final created = await _repository.create(input);
      lastActionMessage = 'Lote creado (id=${created.id})';
      await loadAll();
    });
  }

  Future<void> update(int id, UpdateCoffeeLotInput input) async {
    await _run(() async {
      final updated = await _repository.update(id, input);
      lastActionMessage = 'Lote actualizado (id=${updated.id})';
      await loadAll();
    });
  }

  Future<void> delete(int id) async {
    await _run(() async {
      final msg = await _repository.delete(id);
      lastActionMessage = msg;
      await loadAll();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'Error inesperado: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
