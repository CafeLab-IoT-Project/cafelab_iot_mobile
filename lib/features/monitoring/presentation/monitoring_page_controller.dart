import 'package:cafelab_iot_mobile/features/monitoring/domain/monitoring_repository.dart';
import 'package:flutter/material.dart';
import 'package:cafelab_iot_mobile/features/monitoring/data/monitoring_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/environment_threshold.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/telemetry_record.dart';

class MonitoringPageController extends ChangeNotifier {
  MonitoringPageController({MonitoringRepository? repository})
      : _repository = repository ?? MonitoringRepositoryImpl();

  final MonitoringRepository _repository;

  bool isLoading = false;
  String? errorMessage;

  EnvironmentThreshold? threshold;
  TelemetryRecord? latestTelemetry;
  
  List<TelemetryRecord> telemetryHistory = []; 

  Future<void> loadDashboardData(int lotId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      try {
        threshold = await _repository.getThresholdByLotId(lotId);
      } catch (_) {
        threshold = null;
      }

      final telemetryList = await _repository.getTelemetryByLotId(lotId);
      
      telemetryHistory = telemetryList; 

      if (telemetryList.isNotEmpty) {
        latestTelemetry = telemetryList.last;
      } else {
        latestTelemetry = null;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveThreshold(int lotId, EnvironmentThreshold updatedModel) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (threshold == null) {
        threshold = await _repository.createThreshold(updatedModel);
      } else {
        threshold = await _repository.updateThreshold(lotId, updatedModel);
      }
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}