class CreateSupplierInput {
  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  const CreateSupplierInput({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });
}
