import 'package:cafelab_iot_mobile/features/auth/presentation/confirm_payment_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:flutter/material.dart';

/// Confirmación de pago para usuario con sesión (pago pendiente o cambio de plan).
class ConfirmPaymentSessionPage extends StatelessWidget {
  const ConfirmPaymentSessionPage({
    super.key,
    required this.selectedPlan,
    required this.userRole,
    required this.flowMode,
  }) : assert(
          flowMode == PlanFlowMode.pendingPaymentResume ||
              flowMode == PlanFlowMode.changePlan,
          'ConfirmPaymentSessionPage solo admite flujos de sesión.',
        );

  final SubscriptionPlan selectedPlan;
  final AuthUserRole userRole;
  final PlanFlowMode flowMode;

  @override
  Widget build(BuildContext context) {
    return ConfirmPaymentPage(
      selectedPlan: selectedPlan,
      userRole: userRole,
      flowMode: flowMode,
    );
  }
}
