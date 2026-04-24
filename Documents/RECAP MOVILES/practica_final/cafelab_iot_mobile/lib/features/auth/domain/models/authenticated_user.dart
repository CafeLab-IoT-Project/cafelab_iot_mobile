import 'dart:convert';

class AuthenticatedUser {
  final int id;
  final String email;
  final String role;
  final String token;

  const AuthenticatedUser({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id'] as int,
      email: json['email'] as String,
      role: json['role'] as String,
      token: json['token'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
    };
  }

  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
