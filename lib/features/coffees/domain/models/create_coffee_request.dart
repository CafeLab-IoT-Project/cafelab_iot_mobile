class CreateCoffeeRequest {
  const CreateCoffeeRequest({
    required this.name,
    required this.region,
    required this.variety,
    required this.totalWeight,
  });

  final String name;
  final String region;
  final String variety;
  final double totalWeight;

  Map<String, dynamic> toJson() => {
        'name': name,
        'region': region,
        'variety': variety,
        'totalWeight': totalWeight,
      };
}
