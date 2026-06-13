class ApiFieldValidationError {
  final String field;
  final String message;

  const ApiFieldValidationError({required this.field, required this.message});

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

  const ApiErrorResponse({required this.message, required this.errors});

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
    return errors
        .map((e) => '${_fieldLabelFor(e.field)}: ${e.message}')
        .join('\n');
  }
}

String _fieldLabelFor(String field) {
  return switch (field) {
    'supplier_id' => 'Proveedor',
    'supplierId' => 'Proveedor',
    'lot_name' => 'Nombre del lote',
    'lotName' => 'Nombre del lote',
    'coffee_type' => 'Tipo de cafe',
    'coffeeType' => 'Tipo de cafe',
    'processing_method' => 'Metodo de procesamiento',
    'processingMethod' => 'Metodo de procesamiento',
    'altitude' => 'Altitud',
    'weight' => 'Peso',
    'origin' => 'Origen',
    'status' => 'Estado',
    'certifications' => 'Certificaciones',
    _ => field,
  };
}
