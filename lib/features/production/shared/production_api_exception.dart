import 'package:cafelab_iot_mobile/features/production/shared/api_error_response.dart';

class ProductionApiException implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorResponse? errorResponse;
  final String? rawBody;

  const ProductionApiException(
    this.message, {
    this.statusCode,
    this.errorResponse,
    this.rawBody,
  });

  String get userMessage {
    if (statusCode == 401) {
      return errorResponse?.message ?? 'Sesion expirada o no autenticado';
    }
    if (statusCode == 403) {
      return errorResponse?.message ?? 'No tienes permisos para este recurso';
    }
    if (statusCode == 404) {
      return errorResponse?.message ?? 'Recurso no encontrado';
    }
    if (statusCode == 400) {
      final validationMessage = errorResponse?.userFriendlyValidation();
      if (validationMessage != null && validationMessage.isNotEmpty) {
        return validationMessage;
      }
      if (errorResponse?.message case final backendMessage?
          when backendMessage.isNotEmpty) {
        if (rawBody != null &&
            rawBody!.isNotEmpty &&
            rawBody != backendMessage) {
          return '$backendMessage\nDetalle tecnico: $rawBody';
        }
        return backendMessage;
      }
      if (rawBody != null && rawBody!.isNotEmpty) {
        return 'Error de validacion\nDetalle tecnico: $rawBody';
      }
      return 'Error de validacion';
    }
    if (statusCode == 500) return 'Error interno del servidor';
    return errorResponse?.message ?? message;
  }

  @override
  String toString() {
    if (statusCode == null) return userMessage;
    return '$userMessage (HTTP $statusCode)';
  }
}
