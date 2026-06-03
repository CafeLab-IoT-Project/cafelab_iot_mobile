import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_sessions_page.dart';
import 'package:flutter/material.dart';

class CuppingSessionsTestPage extends StatelessWidget {
  const CuppingSessionsTestPage({
    super.key,
    this.planType = SubscriptionPlanType.full,
  });

  final SubscriptionPlanType planType;

  @override
  Widget build(BuildContext context) {
    return CuppingSessionsPage(planType: planType);
  }
}
