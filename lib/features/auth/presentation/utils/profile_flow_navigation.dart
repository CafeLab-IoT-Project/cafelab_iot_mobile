import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_features.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/profile_constants.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/dashboard_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_session_page.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:flutter/material.dart';

abstract final class ProfileFlowNavigation {
  static AuthUserRole roleFromProfile(String role) {
    final normalized = role.toUpperCase();
    if (normalized.contains('OWNER')) return AuthUserRole.owner;
    return AuthUserRole.barista;
  }

  static bool baristaFullPlanNeedsCafeteriaConfirmation(ProfileModel profile) {
    final role = profile.role.toLowerCase();
    final plan = profile.plan.toLowerCase();
    if (!role.contains('barista') || !plan.contains('full')) return false;
    final cafeteria = profile.cafeteriaName.trim().toLowerCase();
    return cafeteria.isEmpty ||
        cafeteria == ProfileConstants.cafeteriaNotConfirmed;
  }

  /// Tras confirmar pago en cambio de plan: dashboard del plan nuevo o perfil si falta cafetería.
  static void navigateAfterPlanChangePayment(
    BuildContext context, {
    required ProfileModel updatedProfile,
    required SubscriptionPlanType selectedPlanType,
  }) {
    if (baristaFullPlanNeedsCafeteriaConfirmation(updatedProfile)) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const EditProfileSessionPage(),
        ),
        (_) => false,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => DashboardPage(planType: selectedPlanType),
      ),
      (_) => false,
    );
  }

  static void goAfterAuthentication(BuildContext context, ProfileModel profile) {
    if (profile.hasPlan) {
      final planType = DashboardFeatures.planTypeFromApi(profile.plan);
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => DashboardPage(planType: planType),
        ),
        (_) => false,
      );
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => SelectPlansSessionPage(
          userRole: roleFromProfile(profile.role),
        ),
      ),
      (_) => false,
    );
  }
}
