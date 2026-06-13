abstract final class AuthSignUpValidators {
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;

  static final RegExp _namePattern = RegExp(
    r'^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$',
  );
  static final RegExp _emailPattern = RegExp(
    r'^[\w.\-+]+@[\w.\-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _cafeteriaPattern = RegExp(
    r"^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ\s\-'.]+$",
  );

  static Map<String, String> validateBarista({
    required String name,
    required String email,
    required String password,
    required bool hasExperience,
  }) {
    return {
      'name': _validateName(name),
      'email': _validateEmail(email),
      'password': _validatePassword(password),
      'experience': hasExperience ? '' : 'Selecciona tu nivel de experiencia.',
    }..removeWhere((_, value) => value.isEmpty);
  }

  static Map<String, String> validateOwner({
    required String name,
    required String email,
    required String password,
    required String cafeteriaName,
    required bool hasExperience,
  }) {
    return {
      'name': _validateName(name),
      'email': _validateEmail(email),
      'password': _validatePassword(password),
      'cafeteriaName': _validateCafeteriaName(cafeteriaName),
      'experience': hasExperience ? '' : 'Selecciona tus años de experiencia.',
    }..removeWhere((_, value) => value.isEmpty);
  }

  static String _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El nombre es obligatorio.';
    if (trimmed.length < 2) return 'El nombre debe tener al menos 2 letras.';
    if (!_namePattern.hasMatch(trimmed)) {
      return 'El nombre solo puede contener letras y espacios.';
    }
    return '';
  }

  static String validateEmailField(String value) => _validateEmail(value);

  static String _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El correo es obligatorio.';
    if (!_emailPattern.hasMatch(trimmed)) {
      return 'Ingresa un correo electrónico válido.';
    }
    return '';
  }

  static String _validatePassword(String value) {
    if (value.isEmpty) return 'La contraseña es obligatoria.';
    if (value.length < minPasswordLength) {
      return 'La contraseña debe tener al menos $minPasswordLength caracteres.';
    }
    if (value.length > maxPasswordLength) {
      return 'La contraseña no puede superar $maxPasswordLength caracteres.';
    }
    return '';
  }

  static String _validateCafeteriaName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El nombre de la cafetería es obligatorio.';
    if (trimmed.length < 2) {
      return 'El nombre de la cafetería debe tener al menos 2 caracteres.';
    }
    if (!_cafeteriaPattern.hasMatch(trimmed)) {
      return 'Usa solo letras, números y espacios en el nombre de la cafetería.';
    }
    return '';
  }
}
