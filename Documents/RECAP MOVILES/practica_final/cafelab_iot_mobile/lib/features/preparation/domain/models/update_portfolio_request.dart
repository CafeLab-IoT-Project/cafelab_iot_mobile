class UpdatePortfolioRequest {
  const UpdatePortfolioRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() => {'name': name};
}
