class ApiFieldValidationError {
  final String field;
  final String message;

  const ApiFieldValidationError({
    required this.field,
    required this.message,
  });

  factory ApiFieldValidationError.fromJson(Map<String, dynamic> json) {
    return ApiFieldValidationError(
      field: (json['field'] as String?) ?? '',
      message: (json['message'] as String?) ?? 'Valor invalido',
    );
  }
}

class ApiErrorResponse {
  final String message;
  final List<ApiFieldValidationError> errors;

  const ApiErrorResponse({
    required this.message,
    required this.errors,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    final parsedErrors = <ApiFieldValidationError>[];
    if (rawErrors is List) {
      for (final item in rawErrors) {
        if (item is Map<String, dynamic>) {
          parsedErrors.add(ApiFieldValidationError.fromJson(item));
        }
      }
    }
    return ApiErrorResponse(
      message: (json['message'] as String?) ?? 'Error desconocido',
      errors: parsedErrors,
    );
  }

  String userFriendlyValidation() {
    if (errors.isEmpty) return message;
    return errors.map((e) => '${e.field}: ${e.message}').join('\n');
  }
}
