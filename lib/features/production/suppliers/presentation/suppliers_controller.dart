import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/suppliers_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/update_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

class SuppliersController extends ChangeNotifier {
  SuppliersController({SuppliersRepository? repository})
    : _repository = repository ?? SuppliersRepositoryImpl();

  final SuppliersRepository _repository;
  final List<Supplier> _allItems = <Supplier>[];

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? _lastActionMessage;
  String _searchQuery = '';
  Supplier? selected;

  List<Supplier> get items {
    if (_searchQuery.isEmpty) {
      return List<Supplier>.unmodifiable(_allItems);
    }

    final normalizedQuery = _searchQuery.toLowerCase();
    return List<Supplier>.unmodifiable(
      _allItems.where((supplier) {
        return supplier.name.toLowerCase().contains(normalizedQuery) ||
            supplier.email.toLowerCase().contains(normalizedQuery) ||
            supplier.location.toLowerCase().contains(normalizedQuery);
      }),
    );
  }

  bool get hasItems => _allItems.isNotEmpty;

  Future<void> loadSuppliers() async {
    await _run(() async {
      await _refreshItems();
    });
  }

  void updateSearchQuery(String value) {
    _searchQuery = value.trim().toLowerCase();
    notifyListeners();
  }

  void selectSupplier(Supplier supplier) {
    selected = supplier;
    notifyListeners();
  }

  String? consumeActionMessage() {
    final message = _lastActionMessage;
    _lastActionMessage = null;
    return message;
  }

  Future<bool> createSupplier(CreateSupplierInput input) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.create(input);
      await _refreshItems();
      _lastActionMessage = 'Proveedor registrado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> updateSupplier(int supplierId, UpdateSupplierInput input) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.update(supplierId, input);
      await _refreshItems();
      _lastActionMessage = 'Proveedor actualizado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<bool> deleteSupplier(int supplierId) async {
    var isSuccess = false;
    await _run(() async {
      final message = await _repository.delete(supplierId);
      await _refreshItems();
      _lastActionMessage = message.isEmpty
          ? 'Proveedor eliminado correctamente.'
          : message;
      isSuccess = true;
    });
    return isSuccess;
  }

  Future<void> _refreshItems() async {
    final suppliers = await _repository.getAll();
    _allItems
      ..clear()
      ..addAll(suppliers);
    hasLoaded = true;
    if (selected != null) {
      final selectedId = selected!.id;
      selected = _allItems.any((supplier) => supplier.id == selectedId)
          ? _allItems.firstWhere((supplier) => supplier.id == selectedId)
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
