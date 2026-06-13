import 'package:cafelab_iot_mobile/features/auth/presentation/constants/profile_constants.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/auth_sign_up_validators.dart';

abstract final class EditProfileValidators {
  static final RegExp _personNamePattern = RegExp(
    r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$',
  );

  static Map<String, String> validateSession({
    required String firstName,
    required String lastName,
    required String email,
    required bool requiresCafeteria,
    required String cafeteriaName,
  }) {
    return {
      'firstName': _validatePersonName(firstName, 'El nombre'),
      'lastName': _validatePersonName(lastName, 'El apellido'),
      'email': AuthSignUpValidators.validateEmailField(email),
      if (requiresCafeteria) 'cafeteriaName': _validateCafeteriaName(cafeteriaName),
    }..removeWhere((_, value) => value.isEmpty);
  }

  static Map<String, String> validate({
    required String firstName,
    required String lastName,
    required String email,
    required bool isOwner,
    required String cafeteriaName,
  }) {
    return {
      'firstName': _validatePersonName(firstName, 'El nombre'),
      'lastName': _validatePersonName(lastName, 'El apellido'),
      'email': AuthSignUpValidators.validateEmailField(email),
      if (isOwner) 'cafeteriaName': _validateCafeteriaName(cafeteriaName),
    }..removeWhere((_, value) => value.isEmpty);
  }

  static String _validatePersonName(String value, String label) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '$label es obligatorio.';
    if (trimmed.length < 2) {
      return '$label debe tener al menos 2 letras.';
    }
    if (!_personNamePattern.hasMatch(trimmed)) {
      return '$label solo puede contener letras y espacios.';
    }
    return '';
  }

  static String _validateCafeteriaName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El nombre de la cafetería es obligatorio.';
    if (trimmed.toLowerCase() == ProfileConstants.cafeteriaNotConfirmed) {
      return 'Ingresa el nombre real de la cafetería para confirmarlo.';
    }
    if (trimmed.length < 2) {
      return 'El nombre de la cafetería debe tener al menos 2 caracteres.';
    }
    final pattern = RegExp(r"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ\s\-'.]+$");
    if (!pattern.hasMatch(trimmed)) {
      return 'Usa solo letras, números y espacios en el nombre de la cafetería.';
    }
    return '';
  }
}
