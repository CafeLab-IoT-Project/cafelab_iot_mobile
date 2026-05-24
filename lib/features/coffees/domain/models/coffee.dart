class Coffee {
  const Coffee({
    required this.id,
    required this.name,
    required this.region,
    required this.variety,
    required this.totalWeight,
  });

  final int id;
  final String name;
  final String region;
  final String variety;
  final double totalWeight;

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      region: json['region'] as String,
      variety: json['variety'] as String,
      totalWeight: (json['totalWeight'] as num).toDouble(),
    );
  }
}
