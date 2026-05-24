import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_page.dart';
import 'package:flutter/material.dart';

/// Selección de plan durante el registro inicial (antes del primer pago).
class SelectPlansOnboardingPage extends StatelessWidget {
  const SelectPlansOnboardingPage({
    super.key,
    required this.userRole,
  });

  final AuthUserRole userRole;

  @override
  Widget build(BuildContext context) {
    return SelectPlansPage(
      userRole: userRole,
      flowMode: PlanFlowMode.initialOnboarding,
    );
  }
}
