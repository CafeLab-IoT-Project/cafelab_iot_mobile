class UpdateProfileRequest {
  final String name;
  final String email;
  final String? cafeteriaName;
  final String? experience;
  final String? paymentMethod;
  final bool? isFirstLogin;
  final String? plan;
  final bool? hasPlan;

  const UpdateProfileRequest({
    required this.name,
    required this.email,
    this.cafeteriaName,
    this.experience,
    this.paymentMethod,
    this.isFirstLogin,
    this.plan,
    this.hasPlan,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      if (cafeteriaName != null) 'cafeteriaName': cafeteriaName,
      if (experience != null) 'experience': experience,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (isFirstLogin != null) 'isFirstLogin': isFirstLogin,
      if (plan != null) 'plan': plan,
      if (hasPlan != null) 'hasPlan': hasPlan,
    };
  }
}
