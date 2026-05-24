class SignUpRequest {
  final String email;
  final String password;
  final String role;
  final String name;
  final String cafeteriaName;
  final String experience;
  final String profilePicture;
  final String paymentMethod;
  final bool isFirstLogin;
  final String plan;
  final bool hasPlan;

  const SignUpRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.cafeteriaName,
    required this.experience,
    required this.paymentMethod,
    this.role = 'barista',
    this.profilePicture = '',
    this.isFirstLogin = true,
    this.plan = 'free',
    this.hasPlan = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
