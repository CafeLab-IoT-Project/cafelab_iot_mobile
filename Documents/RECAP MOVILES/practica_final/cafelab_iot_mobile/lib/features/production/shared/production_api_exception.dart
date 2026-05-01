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
    if (statusCode == 401) return 'Sesion expirada o no autenticado';
    if (statusCode == 403) {
      return errorResponse?.message ?? 'No tienes permisos para este recurso';
    }
    if (statusCode == 404) return 'Recurso no encontrado';
    if (statusCode == 400) {
      return errorResponse?.userFriendlyValidation() ??
          errorResponse?.message ??
          'Error de validacion';
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
