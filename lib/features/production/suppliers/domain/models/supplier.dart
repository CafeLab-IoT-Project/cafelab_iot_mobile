class Supplier {
  final int id;
  final int userId;
  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  const Supplier({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });
}
