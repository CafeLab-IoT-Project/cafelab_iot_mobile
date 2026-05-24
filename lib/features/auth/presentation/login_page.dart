import 'dart:io';

import 'package:cafelab_iot_mobile/features/auth/data/auth_api_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_in_request.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/barista_sign_up_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/profile_flow_navigation.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_onboarding_service.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/owner_sign_up_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_card.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_screen_background.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_secondary_button.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authRepository = AuthRepositoryImpl();
  final _onboardingService = ProfileOnboardingService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String _apiLoginError = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _openBaristaSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const BaristaSignUpPage(),
      ),
    );
  }

  void _openOwnerSignUp() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const OwnerSignUpPage(),
      ),
    );
  }

  Future<void> _submitLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _apiLoginError = 'Completa correo y contraseña.';
      });
      return;
    }

    if (!email.contains('@')) {
      setState(() {
        _apiLoginError = 'Ingresa un correo electrónico válido.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _apiLoginError = '';
    });

    try {
      await _authRepository.signIn(
        SignInRequest(email: email, password: password),
      );
      final profile = await _onboardingService.fetchCurrentProfile();
      if (!mounted) return;
      ProfileFlowNavigation.goAfterAuthentication(context, profile);
    } on AuthApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiLoginError = _mapLoginError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _apiLoginError = 'Error inesperado al iniciar sesión.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _mapLoginError(AuthApiException error) {
    final statusCode = error.statusCode;
    if (statusCode == HttpStatus.notFound ||
        statusCode == HttpStatus.unauthorized ||
        statusCode == HttpStatus.internalServerError) {
      return 'Correo o contraseña incorrectos.';
    }

    return error.apiError?.message ?? error.message;
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
                      title: 'Iniciar Sesion',
                      children: [
                        if (_apiLoginError.isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Text(
                              _apiLoginError,
                              style: TextStyle(
                                color: Colors.red.shade800,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        AuthFormField(
                          controller: _emailController,
                          hintText: 'Correo electrónico*',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 12),
                        AuthFormField(
                          controller: _passwordController,
                          hintText: 'Contraseña*',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          enabled: !_isLoading,
                          onSubmitted: (_) => _submitLogin(),
                          suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
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
                          label: 'Ingresar',
                          isLoading: _isLoading,
                          onPressed: _submitLogin,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AuthSecondaryButton(
                                label: 'Registrarse como Barista',
                                onPressed: _isLoading ? null : _openBaristaSignUp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AuthSecondaryButton(
                                label: 'Registrarse como Dueño de Cafetería',
                                onPressed: _isLoading ? null : _openOwnerSignUp,
                              ),
                            ),
                          ],
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
