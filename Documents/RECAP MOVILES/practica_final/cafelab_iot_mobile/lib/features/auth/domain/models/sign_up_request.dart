class SignUpRequest {
  final String email;
  final String password;
  final String role;

  const SignUpRequest({
    required this.email,
    required this.password,
    this.role = 'ROLE_USER',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }
}
