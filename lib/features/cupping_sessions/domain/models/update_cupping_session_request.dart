import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';

class UpdateCuppingSessionRequest {
  const UpdateCuppingSessionRequest({
    required this.name,
    required this.origin,
    required this.variety,
    required this.processing,
    required this.sessionDate,
    required this.favorite,
    this.resultsJson,
    this.roastStyleNotes,
  });

  final String name;
  final String origin;
  final String variety;
  final String processing;
  final DateTime sessionDate;
  final bool favorite;
  final String? resultsJson;
  final String? roastStyleNotes;

  Map<String, dynamic> toJson() => {
        'name': name,
        'origin': origin,
        'variety': variety,
        'processing': processing,
        'sessionDate': cuppingSessionDateToWire(sessionDate),
        'favorite': favorite,
        'resultsJson': resultsJson,
        'roastStyleNotes': roastStyleNotes,
      };
}
