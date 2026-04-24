class ProfileModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic> raw;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.raw,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: (json['id'] as num?)?.toInt() ?? -1,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      raw: json,
    );
  }
}
