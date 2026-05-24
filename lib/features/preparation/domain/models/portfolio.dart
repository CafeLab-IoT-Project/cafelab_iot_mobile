class Portfolio {
  const Portfolio({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String name;
  final String createdAt;

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      name: json['name'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}
