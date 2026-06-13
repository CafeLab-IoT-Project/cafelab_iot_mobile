import 'package:cafelab_iot_mobile/features/monitoring/data/monitoring_api_service.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/environment_threshold.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/telemetry_record.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/monitoring_repository.dart';

class MonitoringRepositoryImpl implements MonitoringRepository {
  MonitoringRepositoryImpl({MonitoringApiService? apiService})
      : _apiService = apiService ?? MonitoringApiService();

  final MonitoringApiService _apiService;

  @override
  Future<EnvironmentThreshold> createThreshold(EnvironmentThreshold threshold) async {
    return await _getApiServiceResult(() => _apiService.createThreshold(threshold));
  }

  @override
  Future<EnvironmentThreshold> getThresholdByLotId(int coffeeLotId) async {
    return await _getApiServiceResult(() => _apiService.getThresholdByLotId(coffeeLotId));
  }

  @override
  Future<EnvironmentThreshold> updateThreshold(int coffeeLotId, EnvironmentThreshold threshold) async {
    return await _getApiServiceResult(() => _apiService.updateThreshold(coffeeLotId, threshold));
  }

  @override
  Future<List<TelemetryRecord>> getTelemetryByLotId(int coffeeLotId) async {
    return await _getApiServiceResult(() => _apiService.getTelemetryByLotId(coffeeLotId));
  }


  Future<T> _getApiServiceResult<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } on MonitoringApiException {
      rethrow;
    } catch (e) {
      throw MonitoringApiException(
        'Error inesperado en la capa de datos de Monitoreo: $e',
      );
    }
  }
}