import 'package:cafelab_iot_mobile/core/config/api_config.dart';
import 'package:cafelab_iot_mobile/features/auth/data/auth_api_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/auth_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_in_request.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';
import 'package:flutter/material.dart';

class AuthTestPage extends StatefulWidget {
  const AuthTestPage({super.key});

  @override
  State<AuthTestPage> createState() => _AuthTestPageState();
}

class _AuthTestPageState extends State<AuthTestPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController(text: 'ROLE_USER');
  final _authRepository = AuthRepositoryImpl();

  bool _isLoading = false;
  String _status = 'Idle';
  String _resultText = 'Sin llamadas todavía.';
  String _savedTokenPreview = 'No token';

  @override
  void initState() {
    super.initState();
    _refreshSavedToken();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _refreshSavedToken() async {
    final token = await _authRepository.getToken();
    if (!mounted) return;
    setState(() {
      _savedTokenPreview = (token == null || token.isEmpty)
          ? 'No token'
          : '${token.substring(0, token.length > 24 ? 24 : token.length)}...';
    });
  }

  Future<void> _runSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showError('Email y password son obligatorios para Sign In.');
      return;
    }

    await _runRequest(
      label: 'SIGN_IN',
      action: () async {
        final user = await _authRepository.signIn(
          SignInRequest(email: email, password: password),
        );
        _applySuccess(user, expectedCode: 200);
      },
    );
  }

  Future<void> _runSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _roleController.text.trim().isEmpty
        ? 'ROLE_USER'
        : _roleController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('Email y password son obligatorios para Sign Up.');
      return;
    }

    await _runRequest(
      label: 'SIGN_UP',
      action: () async {
        final user = await _authRepository.signUp(
          SignUpRequest(email: email, password: password, role: role),
        );
        _applySuccess(user, expectedCode: 201);
      },
    );
  }

  Future<void> _runRequest({
    required String label,
    required Future<void> Function() action,
  }) async {
    setState(() {
      _isLoading = true;
      _status = '$label - loading...';
    });
    try {
      await action();
      await _refreshSavedToken();
    } on AuthApiException catch (e) {
      _showError(e.toString());
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applySuccess(AuthenticatedUser user, {required int expectedCode}) {
    setState(() {
      _status = 'Success (esperado $expectedCode)';
      _resultText = user.toPrettyJson();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('OK: ${user.email} (${user.role})')),
    );
  }

  Future<void> _clearToken() async {
    await _authRepository.clearToken();
    await _refreshSavedToken();
    if (!mounted) return;
    setState(() {
      _status = 'Token eliminado';
      _resultText = 'Token removido del almacenamiento local.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Token eliminado')),
    );
  }

  void _showError(String message) {
    setState(() {
      _status = 'Error';
      _resultText = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auth Test Page')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Base URL: ${ApiConfig.baseUrl}\nPath: ${ApiConfig.authBasePath}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _isLoading ? null : _runSignUp,
                child: const Text('Sign Up'),
              ),
              ElevatedButton(
                onPressed: _isLoading ? null : _runSignIn,
                child: const Text('Sign In'),
              ),
              OutlinedButton(
                onPressed: _isLoading ? null : _clearToken,
                child: const Text('Clear token'),
              ),
              const SizedBox(height: 16),
              Text('Status: $_status'),
              const SizedBox(height: 8),
              Text('Saved token: $_savedTokenPreview'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(_resultText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
