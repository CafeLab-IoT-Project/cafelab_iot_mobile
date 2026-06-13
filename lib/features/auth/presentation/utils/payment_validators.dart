import 'package:cafelab_iot_mobile/features/auth/presentation/utils/auth_sign_up_validators.dart';

abstract final class PaymentValidators {
  static Map<String, String> validate({
    required bool hasPaymentMethod,
    required String email,
    required String cardNumber,
    required String expiry,
    required String cvc,
    required String cardholder,
    required String country,
  }) {
    return {
      'paymentMethod':
          hasPaymentMethod ? '' : 'Selecciona un método de pago (VISA o Mastercard).',
      'email': AuthSignUpValidators.validateEmailField(email),
      'cardNumber': _validateCardNumber(cardNumber),
      'expiry': _validateExpiry(expiry),
      'cvc': _validateCvc(cvc),
      'cardholder': _validateCardholder(cardholder),
      'country': country.trim().isEmpty ? 'Selecciona un país.' : '',
    }..removeWhere((_, value) => value.isEmpty);
  }

  static String _validateCardNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'El número de tarjeta es obligatorio.';
    if (digits.length != 16) {
      return 'El número de tarjeta debe tener 16 dígitos.';
    }
    return '';
  }

  static String _validateExpiry(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'La fecha de vencimiento es obligatoria.';
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(trimmed)) {
      return 'Usa el formato MM/YY (ej. 08/28).';
    }
    return '';
  }

  static String _validateCvc(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'El CVC es obligatorio.';
    if (digits.length != 3) return 'El CVC debe tener 3 dígitos.';
    return '';
  }

  static String _validateCardholder(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El nombre del titular es obligatorio.';
    if (trimmed.length < 2) {
      return 'El nombre del titular debe tener al menos 2 caracteres.';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$').hasMatch(trimmed)) {
      return 'El titular solo puede contener letras y espacios.';
    }
    return '';
  }
}
