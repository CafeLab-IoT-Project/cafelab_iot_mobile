import 'package:cafelab_iot_mobile/features/monitoring/domain/models/monitoring_alert.dart';
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
  List<MonitoringAlert> alertsHistory = [];

  Future<void> loadDashboardData(int lotId, {bool isInitialLoad = false}) async {
  if (isInitialLoad) {
      isLoading = true;
      notifyListeners();
    }
    
  errorMessage = null;
  notifyListeners();
  try {
    threshold = await _repository.getThresholdByLotId(lotId);
    final telemetryList = await _repository.getTelemetryByLotId(lotId);
    telemetryHistory = telemetryList; 
    latestTelemetry = telemetryList.isNotEmpty ? telemetryList.last : null;
    
    // Carga de alertas
    alertsHistory = await _repository.getAlertsByLotId(lotId);
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