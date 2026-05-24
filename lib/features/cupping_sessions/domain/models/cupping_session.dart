String cuppingSessionDateToWire(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime cuppingSessionDateFromWire(String raw) => DateTime.parse(raw);

class CuppingSession {
  const CuppingSession({
    required this.id,
    required this.userId,
    required this.name,
    required this.origin,
    required this.variety,
    required this.processing,
    required this.sessionDate,
    required this.favorite,
    this.resultsJson,
    this.roastStyleNotes,
  });

  final int id;
  final int userId;
  final String name;
  final String origin;
  final String variety;
  final String processing;
  final DateTime sessionDate;
  final bool favorite;
  final String? resultsJson;
  final String? roastStyleNotes;

  factory CuppingSession.fromJson(Map<String, dynamic> json) {
    return CuppingSession(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      origin: json['origin'] as String,
      variety: json['variety'] as String,
      processing: json['processing'] as String,
      sessionDate: cuppingSessionDateFromWire(json['sessionDate'] as String),
      favorite: json['favorite'] as bool,
      resultsJson: json['resultsJson'] as String?,
      roastStyleNotes: json['roastStyleNotes'] as String?,
    );
  }
}
