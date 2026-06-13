import 'package:cafelab_iot_mobile/features/auth/presentation/confirm_payment_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:flutter/material.dart';

/// Confirmación de pago durante el registro inicial.
class ConfirmPaymentOnboardingPage extends StatelessWidget {
  const ConfirmPaymentOnboardingPage({
    super.key,
    required this.selectedPlan,
    required this.userRole,
  });

  final SubscriptionPlan selectedPlan;
  final AuthUserRole userRole;

  @override
  Widget build(BuildContext context) {
    return ConfirmPaymentPage(
      selectedPlan: selectedPlan,
      userRole: userRole,
      flowMode: PlanFlowMode.initialOnboarding,
    );
  }
}
