class TelemetryRecord {
  final int? id;
  final int coffeeLotId;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  TelemetryRecord({
    this.id,
    required this.coffeeLotId,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory TelemetryRecord.fromJson(Map<String, dynamic> json) {
    return TelemetryRecord(
      id: json['id'] as int?,
      coffeeLotId: json['coffeeLotId'] as int,
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}