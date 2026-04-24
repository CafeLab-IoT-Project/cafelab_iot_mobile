class ApiMessageError {
  final String message;

  const ApiMessageError({required this.message});

  factory ApiMessageError.fromJson(Map<String, dynamic> json) {
    return ApiMessageError(
      message: (json['message'] as String?)?.trim().isNotEmpty == true
          ? json['message'] as String
          : 'Error desconocido',
    );
  }

  Map<String, dynamic> toJson() => {'message': message};
}
