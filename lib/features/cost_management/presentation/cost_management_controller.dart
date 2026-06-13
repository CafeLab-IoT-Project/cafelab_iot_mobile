import 'package:cafelab_iot_mobile/features/cost_management/data/production_cost_records_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/create_production_cost_record_input.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/production_cost_records_repository.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';

class CostManagementController extends ChangeNotifier {
  CostManagementController({ProductionCostRecordsRepository? repository})
      : _repository = repository ?? ProductionCostRecordsRepositoryImpl();

  final ProductionCostRecordsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<ProductionCostRecord> records = [];
  String searchQuery = '';

  List<ProductionCostRecord> get filteredRecords {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return records;
    return records
        .where((record) => record.lotName.toLowerCase().contains(query))
        .toList();
  }

  Future<void> loadRecords() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      records = await _repository.getAll();
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'No se pudieron cargar los registros: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  Future<ProductionCostRecord?> createRecord(
    CreateProductionCostRecordInput input,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _repository.create(input);
      await loadRecords();
      return created;
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = 'No se pudo guardar el cálculo: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> annulRecord(int id, String reason) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repository.annul(id, reason: reason);
      await loadRecords();
      return true;
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'No se pudo anular el registro: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
