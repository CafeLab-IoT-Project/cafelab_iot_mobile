class CostCalculationValidators {
  static String? requiredField(String? value, {String label = 'Campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label es obligatorio';
    }
    return null;
  }

  static String? decimalInRange(
    String? value, {
    required String label,
    required double min,
    required double max,
    int maxDecimals = 2,
  }) {
    final requiredError = requiredField(value, label: label);
    if (requiredError != null) return requiredError;

    final parsed = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (parsed == null) return '$label debe ser un número válido';

    final parts = value.trim().replaceAll(',', '.').split('.');
    if (parts.length == 2 && parts[1].length > maxDecimals) {
      return '$label admite máximo $maxDecimals decimales';
    }

    if (parsed < min) return '$label debe ser al menos $min';
    if (parsed > max) return '$label no puede superar $max';
    return null;
  }

  static String? integerInRange(
    String? value, {
    required String label,
    required int min,
    required int max,
  }) {
    final requiredError = requiredField(value, label: label);
    if (requiredError != null) return requiredError;

    final parsed = int.tryParse(value!.trim());
    if (parsed == null) return '$label debe ser un número entero';
    if (parsed < min || parsed > max) {
      return '$label debe estar entre $min y $max';
    }
    return null;
  }
}
