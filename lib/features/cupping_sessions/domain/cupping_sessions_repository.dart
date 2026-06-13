import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/create_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/update_cupping_session_request.dart';

abstract class CuppingSessionsRepository {
  Future<CuppingSession> create(CreateCuppingSessionRequest request);

  Future<List<CuppingSession>> list();

  Future<CuppingSession> getById(int id);

  Future<CuppingSession> update(int id, UpdateCuppingSessionRequest request);

  Future<void> delete(int id);
}
