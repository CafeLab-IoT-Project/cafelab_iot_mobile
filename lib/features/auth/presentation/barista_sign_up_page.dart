import 'package:cafelab_iot_mobile/features/auth/data/auth_api_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/barista_sign_up_status_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/auth_sign_up_validators.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_api_error_banner.dart';
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
  final _authRepository = AuthRepositoryImpl();

  bool _obscurePassword = true;
  bool _isLoading = false;
  BaristaExperienceLevel? _selectedExperience;
  Map<String, String> _fieldErrors = {};
  String _apiError = '';

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => _clearFieldError('name'));
    _emailController.addListener(() => _clearFieldError('email'));
    _passwordController.addListener(() => _clearFieldError('password'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() {
      _fieldErrors = Map<String, String>.from(_fieldErrors)..remove(field);
    });
  }

  String _experienceApiValue(BaristaExperienceLevel level) {
    return switch (level) {
      BaristaExperienceLevel.inicial => 'initial',
      BaristaExperienceLevel.intermedio => 'intermediate',
      BaristaExperienceLevel.profesional => 'professional',
    };
  }

  Future<void> _onRegister() async {
    final fieldErrors = AuthSignUpValidators.validateBarista(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      hasExperience: _selectedExperience != null,
    );

    if (fieldErrors.isNotEmpty) {
      setState(() {
        _fieldErrors = fieldErrors;
        _apiError = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _fieldErrors = {};
      _apiError = '';
    });

    final request = SignUpRequest(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: 'barista',
      name: _nameController.text.trim(),
      cafeteriaName: '',
      experience: _experienceApiValue(_selectedExperience!),
      paymentMethod: '',
    );

    try {
      await _authRepository.registerAndSignIn(request);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const BaristaSignUpStatusPage(),
        ),
      );
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.apiError?.message ?? e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'Error inesperado al registrar la cuenta.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _selectExperience(BaristaExperienceLevel level) {
    if (_isLoading) return;
    setState(() {
      _selectedExperience = level;
      _fieldErrors = Map<String, String>.from(_fieldErrors)..remove('experience');
    });
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
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
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
                                if (_apiError.isNotEmpty) ...[
                                  AuthApiErrorBanner(message: _apiError),
                                  const SizedBox(height: 12),
                                ],
                                AuthFormField(
                                  controller: _nameController,
                                  hintText: 'Nombre*',
                                  textInputAction: TextInputAction.next,
                                  enabled: !_isLoading,
                                  errorText: _fieldErrors['name'],
                                ),
                                const SizedBox(height: 12),
                                AuthFormField(
                                  controller: _emailController,
                                  hintText: 'Correo electrónico*',
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  enabled: !_isLoading,
                                  errorText: _fieldErrors['email'],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Nivel de Experiencia',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
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
                                        isSelected: _selectedExperience ==
                                            BaristaExperienceLevel.inicial,
                                        onPressed: _isLoading
                                            ? null
                                            : () => _selectExperience(
                                                  BaristaExperienceLevel
                                                      .inicial,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AuthSelectionButton(
                                        label: 'Intermedio',
                                        isSelected: _selectedExperience ==
                                            BaristaExperienceLevel.intermedio,
                                        onPressed: _isLoading
                                            ? null
                                            : () => _selectExperience(
                                                  BaristaExperienceLevel
                                                      .intermedio,
                                                ),
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
                                      isSelected: _selectedExperience ==
                                          BaristaExperienceLevel.profesional,
                                      onPressed: _isLoading
                                          ? null
                                          : () => _selectExperience(
                                                BaristaExperienceLevel
                                                    .profesional,
                                              ),
                                    ),
                                  ),
                                ),
                                if (_fieldErrors['experience'] != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    _fieldErrors['experience']!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                AuthFormField(
                                  controller: _passwordController,
                                  hintText: 'Contraseña*',
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  enabled: !_isLoading,
                                  errorText: _fieldErrors['password'],
                                  onSubmitted: (_) => _onRegister(),
                                  suffixIcon: IconButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AuthColors.primary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AuthPrimaryButton(
                                  label: 'Registrarse',
                                  isLoading: _isLoading,
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
