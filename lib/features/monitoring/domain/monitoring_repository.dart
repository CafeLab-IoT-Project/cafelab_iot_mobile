import 'package:cafelab_iot_mobile/features/monitoring/domain/models/environment_threshold.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/telemetry_record.dart';

abstract class MonitoringRepository {
  Future<EnvironmentThreshold> createThreshold(EnvironmentThreshold threshold);
  Future<EnvironmentThreshold> getThresholdByLotId(int coffeeLotId);
  Future<EnvironmentThreshold> updateThreshold(int coffeeLotId, EnvironmentThreshold threshold);
  Future<List<TelemetryRecord>> getTelemetryByLotId(int coffeeLotId);
}