import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';

enum SubscriptionPlanType { barista, owner, full }

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.type,
    required this.title,
    required this.priceLabel,
    required this.features,
    required this.actionLabel,
  });

  final SubscriptionPlanType type;
  final String title;
  final String priceLabel;
  final List<String> features;
  final String actionLabel;

  bool isVisibleFor(AuthUserRole role) {
    return switch (type) {
      SubscriptionPlanType.full => true,
      SubscriptionPlanType.barista => role == AuthUserRole.barista,
      SubscriptionPlanType.owner => role == AuthUserRole.owner,
    };
  }

  String get apiPlanValue => switch (type) {
        SubscriptionPlanType.barista => 'barista',
        SubscriptionPlanType.owner => 'owner',
        SubscriptionPlanType.full => 'full',
      };
}
