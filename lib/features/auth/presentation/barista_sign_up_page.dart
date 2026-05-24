import 'package:cafelab_iot_mobile/features/auth/presentation/barista_sign_up_status_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_selection_button.dart';
import 'package:flutter/material.dart';

enum BaristaExperienceLevel { inicial, intermedio, profesional }

class BaristaSignUpPage extends StatefulWidget {
  const BaristaSignUpPage({super.key});

  @override
  State<BaristaSignUpPage> createState() => _BaristaSignUpPageState();
}

class _BaristaSignUpPageState extends State<BaristaSignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  BaristaExperienceLevel? _selectedExperience;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
        _passwordController.text.trim().isEmpty) {
      _showPlaceholderMessage('Completa todos los campos obligatorios.');
      return;
    }
    if (_selectedExperience == null) {
      _showPlaceholderMessage('Selecciona tu nivel de experiencia.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BaristaSignUpStatusPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthScreenBackground(
        backgroundAsset: AuthAssets.baristaSignUpBackground,
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
                              title: 'Registro de Barista',
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
                          'Nivel de Experiencia',
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
                                label: 'Inicial',
                                isSelected:
                                    _selectedExperience ==
                                    BaristaExperienceLevel.inicial,
                                onPressed: () {
                                  setState(() {
                                    _selectedExperience =
                                        BaristaExperienceLevel.inicial;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AuthSelectionButton(
                                label: 'Intermedio',
                                isSelected:
                                    _selectedExperience ==
                                    BaristaExperienceLevel.intermedio,
                                onPressed: () {
                                  setState(() {
                                    _selectedExperience =
                                        BaristaExperienceLevel.intermedio;
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
                              label: 'Profesional',
                              isSelected:
                                  _selectedExperience ==
                                  BaristaExperienceLevel.profesional,
                              onPressed: () {
                                setState(() {
                                  _selectedExperience =
                                      BaristaExperienceLevel.profesional;
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
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _onRegister(),
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
