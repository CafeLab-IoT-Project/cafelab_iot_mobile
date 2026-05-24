import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_page.dart';
import 'package:flutter/material.dart';

/// Selección de plan para usuario con sesión (pago pendiente o cambio de plan).
class SelectPlansSessionPage extends StatelessWidget {
  const SelectPlansSessionPage({
    super.key,
    required this.userRole,
    this.flowMode = PlanFlowMode.pendingPaymentResume,
  }) : assert(
          flowMode == PlanFlowMode.pendingPaymentResume ||
              flowMode == PlanFlowMode.changePlan,
          'SelectPlansSessionPage solo admite flujos de sesión.',
        );

  final AuthUserRole userRole;
  final PlanFlowMode flowMode;

  @override
  Widget build(BuildContext context) {
    return SelectPlansPage(
      userRole: userRole,
      flowMode: flowMode,
    );
  }
}
