import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:flutter/material.dart';

/// Pantalla reservada para editar el perfil tras el registro (barista o dueño).
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.userRole,
  });

  final AuthUserRole userRole;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firstNameController = TextEditingController(text: '...');
  final _cafeteriaNameController = TextEditingController(text: '...');
  final _lastNameController = TextEditingController(text: '...');
  final _emailController = TextEditingController(text: '...');

  @override
  void dispose() {
    _firstNameController.dispose();
    _cafeteriaNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _openSelectPlans() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SelectPlansPage(userRole: widget.userRole),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(),
          Expanded(
            child: ColoredBox(
              color: AuthColors.profileScreenBackground,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Editar Perfil',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                      ),
                      const SizedBox(height: 28),
                      _ProfileFieldRow(
                        label: 'Nombres',
                        controller: _firstNameController,
                      ),
                      const SizedBox(height: 20),
                      if (widget.userRole == AuthUserRole.owner)
                        _ProfileFieldRow(
                          label: 'Nombre de Cafetería',
                          controller: _cafeteriaNameController,
                        ),
                      if (widget.userRole == AuthUserRole.owner)
                        const SizedBox(height: 20),
                      _ProfileFieldRow(
                        label: 'Apellidos',
                        controller: _lastNameController,
                      ),
                      const SizedBox(height: 20),
                      _ProfileFieldRow(
                        label: 'Email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 32),
                      AuthPrimaryButton(
                        label: 'Guardar',
                        onPressed: _openSelectPlans,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  const _ProfileFieldRow({
    required this.label,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: true,
                keyboardType: keyboardType,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.45),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AuthColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.edit_outlined,
                    color: AuthColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
