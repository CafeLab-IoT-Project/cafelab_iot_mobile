import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/suppliers_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

class CoffeeLotsController extends ChangeNotifier {
  CoffeeLotsController({
    CoffeeLotsRepository? repository,
    SuppliersRepository? suppliersRepository,
  }) : _repository = repository ?? CoffeeLotsRepositoryImpl(),
       _suppliersRepository = suppliersRepository ?? SuppliersRepositoryImpl();

  final CoffeeLotsRepository _repository;
  final SuppliersRepository _suppliersRepository;
  final List<CoffeeLot> _allItems = <CoffeeLot>[];
  final List<Supplier> _suppliers = <Supplier>[];

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? _lastActionMessage;
  String _searchQuery = '';
  CoffeeLot? selected;
  List<Supplier> get suppliers => List<Supplier>.unmodifiable(_suppliers);

  List<CoffeeLot> get items {
    if (_searchQuery.isEmpty) {
      return List<CoffeeLot>.unmodifiable(_allItems);
    }

    final normalizedQuery = _searchQuery.toLowerCase();
    return List<CoffeeLot>.unmodifiable(
      _allItems.where((item) {
        return item.lotName.toLowerCase().contains(normalizedQuery) ||
            item.coffeeType.toLowerCase().contains(normalizedQuery) ||
            item.origin.toLowerCase().contains(normalizedQuery) ||
            supplierLabelFor(
              item.supplierId,
            ).toLowerCase().contains(normalizedQuery);
      }),
    );
  }

  bool get hasItems => _allItems.isNotEmpty;
  bool get hasSuppliers => _suppliers.isNotEmpty;

  Future<void> loadAll() async {
    await _run(() async {
      await _refreshData();
    });
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  void selectLot(CoffeeLot lot) {
    selected = lot;
    notifyListeners();
  }

  String? consumeActionMessage() {
    final message = _lastActionMessage;
    _lastActionMessage = null;
    return message;
  }

  Future<bool> create(CreateCoffeeLotInput input) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.create(input);
      await _refreshData();
      _lastActionMessage = 'Lote de cafe registrado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> update(int id, UpdateCoffeeLotInput input) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.update(id, input);
      await _refreshData();
      _lastActionMessage = 'Lote de cafe actualizado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> delete(int id) async {
    var isSuccess = false;
    await _run(() async {
      final msg = await _repository.delete(id);
      await _refreshData();
      _lastActionMessage = msg.isEmpty
          ? 'Lote de cafe eliminado correctamente.'
          : msg;
      isSuccess = true;
    });
    return isSuccess;
  }

  String supplierLabelFor(int supplierId) {
    final index = _suppliers.indexWhere(
      (supplier) => supplier.id == supplierId,
    );
    if (index == -1) {
      return 'Proveedor #$supplierId';
    }
    return _suppliers[index].name;
  }

  Future<void> _refreshData() async {
    final results = await Future.wait<dynamic>([
      _repository.getAll(),
      _suppliersRepository.getAll(),
    ]);
    final lots = results[0] as List<CoffeeLot>;
    final suppliers = results[1] as List<Supplier>;
    _allItems
      ..clear()
      ..addAll(lots);
    _suppliers
      ..clear()
      ..addAll(suppliers);
    hasLoaded = true;
    if (selected != null) {
      final selectedId = selected!.id;
      selected = _allItems.any((item) => item.id == selectedId)
          ? _allItems.firstWhere((item) => item.id == selectedId)
          : null;
    }
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
