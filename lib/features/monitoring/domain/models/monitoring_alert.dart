class MonitoringAlert {
  final int id;
  final int coffeeLotId;
  final String metricType;
  final double currentValue;
  final double thresholdViolated;
  final bool isRead;
  final DateTime createdAt;

  MonitoringAlert({
    required this.id,
    required this.coffeeLotId,
    required this.metricType,
    required this.currentValue,
    required this.thresholdViolated,
    required this.isRead,
    required this.createdAt,
  });

factory MonitoringAlert.fromJson(Map<String, dynamic> json) {
    return MonitoringAlert(
      id: json['id'],
      coffeeLotId: json['coffeeLotId'],
      metricType: json['metricType'],
      currentValue: (json['currentValue'] as num).toDouble(),
      thresholdViolated: (json['thresholdViolated'] as num).toDouble(),
      isRead: json['read'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
}
}