class EnvironmentThreshold {
  final int? id;
  final int coffeeLotId;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;

  EnvironmentThreshold({
    this.id,
    required this.coffeeLotId,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
  });

  factory EnvironmentThreshold.fromJson(Map<String, dynamic> json) {
    return EnvironmentThreshold(
      id: json['id'] as int?,
      coffeeLotId: json['coffeeLotId'] as int,
      minTemperature: (json['minTemperature'] as num).toDouble(),
      maxTemperature: (json['maxTemperature'] as num).toDouble(),
      minHumidity: (json['minHumidity'] as num).toDouble(),
      maxHumidity: (json['maxHumidity'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coffeeLotId': coffeeLotId,
      'minTemperature': minTemperature,
      'maxTemperature': maxTemperature,
      'minHumidity': minHumidity,
      'maxHumidity': maxHumidity,
    };
  }
}