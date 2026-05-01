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

  bool isLoading = false;
  String? errorMessage;
  String? lastActionMessage;
  List<Supplier> items = [];
  Supplier? selected;

  Future<void> loadSuppliers() async {
    await _run(() async {
      items = await _repository.getAll();
      lastActionMessage = 'Suppliers cargados';
    });
  }

  Future<void> loadSuppliersByUserId(int userId) async {
    await _run(() async {
      items = await _repository.getByUserId(userId);
      lastActionMessage = 'Filtrado por userId=$userId';
    });
  }

  Future<void> loadSupplierDetail(int supplierId) async {
    await _run(() async {
      selected = await _repository.getById(supplierId);
      lastActionMessage = 'Detalle cargado para supplierId=$supplierId';
    });
  }

  Future<void> createSupplier(CreateSupplierInput input) async {
    await _run(() async {
      final created = await _repository.create(input);
      lastActionMessage = 'Supplier creado (id=${created.id})';
      await loadSuppliers();
    });
  }

  Future<void> updateSupplier(int supplierId, UpdateSupplierInput input) async {
    await _run(() async {
      final updated = await _repository.update(supplierId, input);
      lastActionMessage = 'Supplier actualizado (id=${updated.id})';
      await loadSuppliers();
    });
  }

  Future<void> deleteSupplier(int supplierId) async {
    await _run(() async {
      final message = await _repository.delete(supplierId);
      lastActionMessage = message;
      await loadSuppliers();
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
