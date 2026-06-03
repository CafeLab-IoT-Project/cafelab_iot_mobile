import 'dart:math' as math;

import 'package:cafelab_iot_mobile/features/management/data/management_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/management/domain/management_repository.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/models/inventory_view_models.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/data/suppliers_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/suppliers_repository.dart';
import 'package:flutter/foundation.dart';

class InventoryController extends ChangeNotifier {
  InventoryController({
    ManagementRepository? repository,
    CoffeeLotsRepository? coffeeLotsRepository,
    SuppliersRepository? suppliersRepository,
  }) : _repository = repository ?? ManagementRepositoryImpl(),
       _coffeeLotsRepository = coffeeLotsRepository ?? CoffeeLotsRepositoryImpl(),
       _suppliersRepository = suppliersRepository ?? SuppliersRepositoryImpl();

  final ManagementRepository _repository;
  final CoffeeLotsRepository _coffeeLotsRepository;
  final SuppliersRepository _suppliersRepository;

  final List<InventoryEntry> _entries = <InventoryEntry>[];
  final List<CoffeeLot> _lots = <CoffeeLot>[];
  final List<Supplier> _suppliers = <Supplier>[];

  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? _lastActionMessage;
  InventoryGrainType _selectedGrainType = InventoryGrainType.green;
  String? _selectedCoffeeType;

  InventoryGrainType get selectedGrainType => _selectedGrainType;
  String? get selectedCoffeeType => _selectedCoffeeType;
  bool get hasData => _entries.isNotEmpty || _lots.isNotEmpty;
  bool get hasLots => _lots.isNotEmpty;

  List<InventoryLotSnapshot> get lotSnapshots {
    final consumedByLot = <int, double>{};
    for (final entry in _entries) {
      consumedByLot.update(
        entry.coffeeLotId,
        (value) => value + entry.quantityUsed,
        ifAbsent: () => entry.quantityUsed,
      );
    }

    final suppliersById = <int, Supplier>{
      for (final supplier in _suppliers) supplier.id: supplier,
    };

    return List<InventoryLotSnapshot>.unmodifiable(
      _lots.map((lot) {
        final consumed = consumedByLot[lot.id] ?? 0;
        final currentStock = math.max(0.0, lot.weight - consumed);
        return InventoryLotSnapshot(
          lot: lot,
          supplier: suppliersById[lot.supplierId],
          consumed: consumed,
          currentStock: currentStock,
        );
      }),
    );
  }

  List<InventoryLotSnapshot> get grainLots {
    return List<InventoryLotSnapshot>.unmodifiable(
      lotSnapshots.where((snapshot) => snapshot.grainType == _selectedGrainType),
    );
  }

  List<String> get availableCoffeeTypes {
    final types = grainLots
        .map((snapshot) => snapshot.lot.coffeeType.trim())
        .where((type) => type.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return List<String>.unmodifiable(types);
  }

  List<InventoryLotSnapshot> get selectedLots {
    return List<InventoryLotSnapshot>.unmodifiable(
      grainLots.where((snapshot) {
        if (_selectedCoffeeType == null || _selectedCoffeeType!.isEmpty) {
          return true;
        }
        return snapshot.lot.coffeeType == _selectedCoffeeType;
      }),
    );
  }

  List<InventoryLotSnapshot> get availableLotsForRegistration {
    return List<InventoryLotSnapshot>.unmodifiable(
      selectedLots.where((snapshot) => snapshot.hasStock),
    );
  }

  List<InventoryEntryRecord> get historyItems {
    final snapshotsByLotId = <int, InventoryLotSnapshot>{
      for (final snapshot in lotSnapshots) snapshot.lot.id: snapshot,
    };

    final records = _entries
        .map(
          (entry) => InventoryEntryRecord(
            entry: entry,
            lotSnapshot: snapshotsByLotId[entry.coffeeLotId],
          ),
        )
        .where((record) => record.grainType == _selectedGrainType)
        .where((record) {
          if (_selectedCoffeeType == null || _selectedCoffeeType!.isEmpty) {
            return true;
          }
          return record.coffeeTypeLabel == _selectedCoffeeType;
        })
        .toList()
      ..sort((a, b) => b.entry.dateUsed.compareTo(a.entry.dateUsed));

    return List<InventoryEntryRecord>.unmodifiable(records);
  }

  InventorySummaryData get summary {
    final totalStock = grainLots.fold<double>(
      0,
      (total, snapshot) => total + snapshot.currentStock,
    );
    final selectedTypeStock = selectedLots.fold<double>(
      0,
      (total, snapshot) => total + snapshot.currentStock,
    );
    final activeLotsCount =
        selectedLots.where((snapshot) => snapshot.hasStock).length;
    final suppliersCount = selectedLots
        .map((snapshot) => snapshot.lot.supplierId)
        .toSet()
        .length;

    return InventorySummaryData(
      totalStock: totalStock,
      selectedCoffeeType: _selectedCoffeeType ?? 'Sin tipo disponible',
      selectedTypeStock: selectedTypeStock,
      activeLotsCount: activeLotsCount,
      suppliersCount: suppliersCount,
    );
  }

  Future<void> loadAll() async {
    await _run(() async {
      await _refreshData();
    });
  }

  void selectGrainType(InventoryGrainType value) {
    if (_selectedGrainType == value) {
      return;
    }
    _selectedGrainType = value;
    _syncSelectedCoffeeType();
    notifyListeners();
  }

  void selectCoffeeType(String? value) {
    _selectedCoffeeType = value?.trim().isEmpty ?? true ? null : value?.trim();
    notifyListeners();
  }

  InventoryLotSnapshot? lotSnapshotById(int lotId) {
    for (final snapshot in lotSnapshots) {
      if (snapshot.lot.id == lotId) {
        return snapshot;
      }
    }
    return null;
  }

  List<InventoryEntryRecord> previousMovementsForLot(
    int lotId, {
    DateTime? beforeDate,
  }) {
    final snapshotsByLotId = <int, InventoryLotSnapshot>{
      for (final snapshot in lotSnapshots) snapshot.lot.id: snapshot,
    };

    final records = _entries
        .where((entry) => entry.coffeeLotId == lotId)
        .where((entry) => beforeDate == null || !entry.dateUsed.isAfter(beforeDate))
        .map(
          (entry) => InventoryEntryRecord(
            entry: entry,
            lotSnapshot: snapshotsByLotId[entry.coffeeLotId],
          ),
        )
        .toList()
      ..sort((a, b) => b.entry.dateUsed.compareTo(a.entry.dateUsed));

    return List<InventoryEntryRecord>.unmodifiable(records);
  }

  Future<bool> registerConsumption(CreateInventoryEntryRequest request) async {
    var isSuccess = false;
    await _run(() async {
      await _repository.createInventoryEntry(request);
      await _refreshData();
      _lastActionMessage = 'Consumo registrado correctamente.';
      isSuccess = true;
    });
    return isSuccess;
  }

  String? consumeActionMessage() {
    final message = _lastActionMessage;
    _lastActionMessage = null;
    return message;
  }

  Future<void> _refreshData() async {
    final results = await Future.wait<dynamic>([
      _repository.listInventoryEntries(),
      _coffeeLotsRepository.getAll(),
      _suppliersRepository.getAll(),
    ]);

    _entries
      ..clear()
      ..addAll(results[0] as List<InventoryEntry>);
    _lots
      ..clear()
      ..addAll(results[1] as List<CoffeeLot>);
    _suppliers
      ..clear()
      ..addAll(results[2] as List<Supplier>);

    hasLoaded = true;
    _syncSelectedCoffeeType();
  }

  void _syncSelectedCoffeeType() {
    final types = availableCoffeeTypes;
    if (types.isEmpty) {
      _selectedCoffeeType = null;
      return;
    }

    if (_selectedCoffeeType == null || !types.contains(_selectedCoffeeType)) {
      _selectedCoffeeType = types.first;
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
