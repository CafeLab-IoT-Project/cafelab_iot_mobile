import 'package:cafelab_iot_mobile/features/auth/presentation/barista_sign_up_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/owner_sign_up_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/sign_in_loading_page.dart';
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
  bool _obscurePassword = true;

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

  void _openSignInLoading() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SignInLoadingPage(),
      ),
    );
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
                        AuthFormField(
                          controller: _emailController,
                          hintText: 'Correo electrónico*',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        AuthFormField(
                          controller: _passwordController,
                          hintText: 'Contraseña*',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _openSignInLoading(),
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
                          label: 'Ingresar',
                          onPressed: _openSignInLoading,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AuthSecondaryButton(
                                label: 'Registrarse como Barista',
                                onPressed: _openBaristaSignUp,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AuthSecondaryButton(
                                label: 'Registrarse como Dueño de Cafetería',
                                onPressed: _openOwnerSignUp,
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
