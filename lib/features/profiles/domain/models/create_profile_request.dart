class CreateProfileRequest {
  final String name;
  final String email;
  final String password;
  final String role;
  final String cafeteriaName;
  final String experience;
  final String profilePicture;
  final String paymentMethod;
  final bool isFirstLogin;
  final String plan;
  final bool hasPlan;

  const CreateProfileRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.cafeteriaName = '',
    this.experience = '',
    this.profilePicture = '',
    this.paymentMethod = '',
    this.isFirstLogin = true,
    this.plan = '',
    this.hasPlan = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'cafeteriaName': cafeteriaName,
      'experience': experience,
      'profilePicture': profilePicture,
      'paymentMethod': paymentMethod,
      'isFirstLogin': isFirstLogin,
      'plan': plan,
      'hasPlan': hasPlan,
    };
  }
}
