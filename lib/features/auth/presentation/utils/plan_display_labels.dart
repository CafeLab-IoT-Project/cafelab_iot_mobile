import 'package:cafelab_iot_mobile/features/auth/presentation/constants/subscription_plans.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';

abstract final class PlanDisplayLabels {
  static String fromApiPlan(String plan) {
    final normalized = plan.toLowerCase();
    if (normalized.contains('owner')) {
      return SubscriptionPlans.owner.title;
    }
    if (normalized.contains('full')) {
      return SubscriptionPlans.full.title;
    }
    return SubscriptionPlans.barista.title;
  }

  static SubscriptionPlanType typeFromApi(String plan) {
    final normalized = plan.toLowerCase();
    if (normalized.contains('owner')) return SubscriptionPlanType.owner;
    if (normalized.contains('full')) return SubscriptionPlanType.full;
    return SubscriptionPlanType.barista;
  }
}
