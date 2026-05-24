import 'package:cafelab_iot_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/login_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:flutter/material.dart';

/// Pantalla estática de demostración tras un inicio de sesión exitoso.
class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({
    super.key,
    required this.user,
  });

  final AuthenticatedUser user;

  Future<void> _signOut(BuildContext context) async {
    await AuthRepositoryImpl().clearToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  String get _roleLabel {
    final role = user.role.toUpperCase();
    if (role.contains('OWNER')) return 'Dueño de cafetería';
    if (role.contains('BARISTA')) return 'Barista';
    return user.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenBackground(
        backgroundAsset: AuthAssets.loginBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: AuthFormCard(
                      title: 'Sesión iniciada',
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 56,
                          color: AuthColors.header,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '¡Bienvenido de nuevo!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Has accedido correctamente con tu cuenta.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                        ),
                        const SizedBox(height: 24),
                        _InfoRow(label: 'Correo', value: user.email),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Rol', value: _roleLabel),
                        const SizedBox(height: 8),
                        _InfoRow(label: 'ID', value: user.id.toString()),
                        const SizedBox(height: 24),
                        AuthPrimaryButton(
                          label: 'Continuar',
                          onPressed: () {},
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => _signOut(context),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AuthColors.inputBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
