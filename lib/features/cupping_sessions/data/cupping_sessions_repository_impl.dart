import 'package:cafelab_iot_mobile/features/cupping_sessions/data/cupping_sessions_api_service.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/cupping_sessions_repository.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/create_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/update_cupping_session_request.dart';

class CuppingSessionsRepositoryImpl implements CuppingSessionsRepository {
  CuppingSessionsRepositoryImpl({CuppingSessionsApiService? apiService})
      : _apiService = apiService ?? CuppingSessionsApiService();

  final CuppingSessionsApiService _apiService;

  @override
  Future<CuppingSession> create(CreateCuppingSessionRequest request) {
    return _apiService.create(request);
  }

  @override
  Future<List<CuppingSession>> list() {
    return _apiService.list();
  }

  @override
  Future<CuppingSession> getById(int id) {
    return _apiService.getById(id);
  }

  @override
  Future<CuppingSession> update(int id, UpdateCuppingSessionRequest request) {
    return _apiService.update(id, request);
  }

  @override
  Future<void> delete(int id) {
    return _apiService.delete(id);
  }
}
