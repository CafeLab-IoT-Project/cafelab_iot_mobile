import 'package:cafelab_iot_mobile/features/calibrations/data/calibrations_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/calibrations_repository.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/foundation.dart';

class GrindCalibrationController extends ChangeNotifier {
  GrindCalibrationController({CalibrationsRepository? repository})
      : _repository = repository ?? CalibrationsRepositoryImpl();

  final CalibrationsRepository _repository;

  bool isLoading = false;
  String? errorMessage;
  List<GrindCalibration> items = [];
  String searchQuery = '';

  List<GrindCalibration> get filteredItems {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.method.toLowerCase().contains(query) ||
          item.equipment.toLowerCase().contains(query) ||
          item.grindNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> loadCalibrations() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      items = await _repository.list();
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'No se pudieron cargar las calibraciones: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<GrindCalibration?> getById(int id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      return await _repository.getById(id);
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = 'No se pudo cargar la calibración: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<GrindCalibration?> create(CreateGrindCalibrationRequest request) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final created = await _repository.create(request);
      await loadCalibrations();
      return created;
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = 'No se pudo registrar la calibración: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<GrindCalibration?> update(
    int id,
    UpdateGrindCalibrationRequest request,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final updated = await _repository.update(id, request);
      await loadCalibrations();
      return updated;
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
      isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      errorMessage = 'No se pudo actualizar la calibración: $e';
      isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void updateSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }
}
