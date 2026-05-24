import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/owner_sign_up_status_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_selection_button.dart';
import 'package:flutter/material.dart';

enum OwnerExperienceYears { zeroToThree, fourToSeven, eightOrMore }

class OwnerSignUpPage extends StatefulWidget {
  const OwnerSignUpPage({super.key});

  @override
  State<OwnerSignUpPage> createState() => _OwnerSignUpPageState();
}

class _OwnerSignUpPageState extends State<OwnerSignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cafeteriaNameController = TextEditingController();

  bool _obscurePassword = true;
  OwnerExperienceYears? _selectedExperience;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _cafeteriaNameController.dispose();
    super.dispose();
  }

  void _showPlaceholderMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onRegister() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _cafeteriaNameController.text.trim().isEmpty) {
      _showPlaceholderMessage('Completa todos los campos obligatorios.');
      return;
    }
    if (_selectedExperience == null) {
      _showPlaceholderMessage('Selecciona tus años de experiencia.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OwnerSignUpStatusPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenBackground(
        backgroundAsset: AuthAssets.ownerSignUpBackground,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeader(),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AuthPillButton(
                          label: 'Volver',
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AuthFormCard(
                              title: 'Registro de Dueño de Cafetería',
                              children: [
                        AuthFormField(
                          controller: _nameController,
                          hintText: 'Nombre*',
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        AuthFormField(
                          controller: _emailController,
                          hintText: 'Correo electrónico*',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Años de experiencia',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AuthSelectionButton(
                                label: '0 - 3 años',
                                isSelected:
                                    _selectedExperience ==
                                    OwnerExperienceYears.zeroToThree,
                                onPressed: () {
                                  setState(() {
                                    _selectedExperience =
                                        OwnerExperienceYears.zeroToThree;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AuthSelectionButton(
                                label: '4 - 7 años',
                                isSelected:
                                    _selectedExperience ==
                                    OwnerExperienceYears.fourToSeven,
                                onPressed: () {
                                  setState(() {
                                    _selectedExperience =
                                        OwnerExperienceYears.fourToSeven;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          child: SizedBox(
                            width: 160,
                            child: AuthSelectionButton(
                              label: '8 o más años',
                              isSelected:
                                  _selectedExperience ==
                                  OwnerExperienceYears.eightOrMore,
                              onPressed: () {
                                setState(() {
                                  _selectedExperience =
                                      OwnerExperienceYears.eightOrMore;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthFormField(
                          controller: _passwordController,
                          hintText: 'Contraseña*',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AuthColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AuthFormField(
                          controller: _cafeteriaNameController,
                          hintText: 'Nombre de la Cafetería*',
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onRegister(),
                        ),
                        const SizedBox(height: 20),
                        AuthPrimaryButton(
                          label: 'Registrarse',
                          onPressed: _onRegister,
                        ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
