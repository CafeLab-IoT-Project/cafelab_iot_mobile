import 'package:cafelab_iot_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';

class AuthenticatedMenuDrawer extends StatelessWidget {
  const AuthenticatedMenuDrawer({
    super.key,
    required this.onFeatures,
    this.onProfile,
    this.onBeforeLogout,
  });

  final VoidCallback onFeatures;
  final VoidCallback? onProfile;
  final Future<void> Function()? onBeforeLogout;

  Future<void> _logout(BuildContext context) async {
    Navigator.of(context).pop();
    if (onBeforeLogout != null) {
      await onBeforeLogout!();
    }
    await AuthRepositoryImpl().clearToken();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
  final drawerWidth = MediaQuery.sizeOf(context).width * 0.78;

    return Drawer(
      width: drawerWidth,
      backgroundColor: AuthColors.header,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MenuItem(
                label: 'Funcionalidades',
                onTap: () {
                  Navigator.of(context).pop();
                  onFeatures();
                },
              ),
              const SizedBox(height: 28),
              _MenuItem(
                label: 'Perfil',
                onTap: onProfile == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        onProfile!();
                      },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: Material(
                  color: const Color(0xFFC62828),
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () => _logout(context),
                    borderRadius: BorderRadius.circular(24),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Cerrar sesión',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: TextStyle(
        color: Colors.white.withValues(alpha: onTap == null ? 0.85 : 1),
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
    );

    if (onTap == null) {
      return child;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: child,
      ),
    );
  }
}
