import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_features.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/dashboard_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/login_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_session_page.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_onboarding_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:flutter/material.dart';

/// Resuelve la pantalla inicial según sesión y estado de plan (`hasPlan`).
class AppRootPage extends StatefulWidget {
  const AppRootPage({super.key});

  @override
  State<AppRootPage> createState() => _AppRootPageState();
}

class _AppRootPageState extends State<AppRootPage> {
  final _onboardingService = ProfileOnboardingService();

  @override
  void initState() {
    super.initState();
    _resolveInitialRoute();
  }

  Future<void> _resolveInitialRoute() async {
    final tokenStorage = TokenStorageService();
    final token = await tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _goLogin();
      return;
    }

    try {
      final profile = await _onboardingService.fetchCurrentProfile();
      if (!mounted) return;

      if (!profile.hasPlan) {
        final role = _roleFromProfile(profile.role);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => SelectPlansSessionPage(userRole: role),
          ),
        );
        return;
      }

      final planType = DashboardFeatures.planTypeFromApi(profile.plan);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => DashboardPage(planType: planType),
        ),
      );
    } on ProfileApiException {
      _goLogin();
    } catch (_) {
      _goLogin();
    }
  }

  AuthUserRole _roleFromProfile(String role) {
    final normalized = role.toUpperCase();
    if (normalized.contains('OWNER')) return AuthUserRole.owner;
    return AuthUserRole.barista;
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
