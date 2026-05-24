import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';

abstract final class SubscriptionPlans {
  static const barista = SubscriptionPlan(
    type: SubscriptionPlanType.barista,
    title: 'Plan Barista',
    priceLabel: r'$9 / mes',
    features: [
      'Sesiones de cata',
      'Librería de defectos',
      'Correlación Tueste-Sabor',
      'Calibración de Molienda',
      'Recetas',
    ],
    actionLabel: 'Comenzar Plan Barista',
  );

  static const owner = SubscriptionPlan(
    type: SubscriptionPlanType.owner,
    title: 'Plan Dueño/Administrador',
    priceLabel: r'$9 / mes',
    features: [
      'Proveedores',
      'Inventario',
      'Lotes de café',
      'Gestión de costos',
      'Perfiles de tueste',
    ],
    actionLabel: 'Comenzar Plan Dueño/Administrador',
  );

  static const full = SubscriptionPlan(
    type: SubscriptionPlanType.full,
    title: 'Plan Completo',
    priceLabel: r'$15 / mes',
    features: [
      'Plan Barista',
      'Plan Dueño/Administrador',
    ],
    actionLabel: 'Comenzar Plan Completo',
  );

  static const List<SubscriptionPlan> all = [barista, owner, full];

  static List<SubscriptionPlan> forRole(AuthUserRole role) {
    return all.where((plan) => plan.isVisibleFor(role)).toList();
  }
}
