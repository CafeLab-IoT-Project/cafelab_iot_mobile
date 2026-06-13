/// Rol elegido durante el registro. Se usará para filtrar planes visibles.
enum AuthUserRole {
  barista,
  owner;

  /// Valor esperado por el backend (`barista` | `owner`).
  String get apiValue => switch (this) {
    AuthUserRole.barista => 'barista',
    AuthUserRole.owner => 'owner',
  };

  static AuthUserRole? fromApiValue(String? value) {
    switch (value?.toLowerCase()) {
      case 'barista':
        return AuthUserRole.barista;
      case 'owner':
        return AuthUserRole.owner;
      default:
        return null;
    }
  }
}
