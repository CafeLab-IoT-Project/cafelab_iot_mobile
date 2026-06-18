import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_id.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_item.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';

abstract final class DashboardFeatures {
  static const barista = [
    DashboardFeatureItem(
      id: DashboardFeatureId.cuppingSessions,
      title: 'Sesiones de cata',
      imageAsset: DashboardAssets.catas,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.defectLibrary,
      title: 'Librería de defectos',
      imageAsset: DashboardAssets.defects,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.grindCalibration,
      title: 'Calibración de molienda',
      imageAsset: DashboardAssets.calibracion,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.recipes,
      title: 'Recetas',
      imageAsset: DashboardAssets.recetas,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.monitoring,
      title: 'Monitoreo',
      imageAsset: DashboardAssets.monitoreo,
    ),
  ];

  static const owner = [
    DashboardFeatureItem(
      id: DashboardFeatureId.suppliers,
      title: 'Proveedores',
      imageAsset: DashboardAssets.suppliers,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.coffeeLots,
      title: 'Lotes de café',
      imageAsset: DashboardAssets.lots,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.roastProfiles,
      title: 'Perfiles de tueste',
      imageAsset: DashboardAssets.roastProfiles,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.inventory,
      title: 'Inventario',
      imageAsset: DashboardAssets.inventario,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.productionCost,
      title: 'Gestión de costos',
      imageAsset: DashboardAssets.costos,
    ),
    DashboardFeatureItem(
      id: DashboardFeatureId.monitoring,
      title: 'Monitoreo',
      imageAsset: DashboardAssets.monitoreo,
    ),
  ];

  static List<DashboardFeatureItem> get full {
    final items = <DashboardFeatureItem>[];
    final seen = <DashboardFeatureId>{};
    for (final feature in [...barista, ...owner]) {
      if (seen.add(feature.id)) {
        items.add(feature);
      }
    }
    return items;
  }

  static List<DashboardFeatureItem> forPlanType(SubscriptionPlanType type) {
    return switch (type) {
      SubscriptionPlanType.barista => barista,
      SubscriptionPlanType.owner => owner,
      SubscriptionPlanType.full => full,
    };
  }

  static bool isFeatureAvailable(
    DashboardFeatureId id,
    SubscriptionPlanType planType,
  ) {
    return forPlanType(planType).any((feature) => feature.id == id);
  }

  static SubscriptionPlanType planTypeFromApi(String plan) {
    final normalized = plan.toLowerCase();
    if (normalized.contains('owner')) return SubscriptionPlanType.owner;
    if (normalized.contains('full')) return SubscriptionPlanType.full;
    return SubscriptionPlanType.barista;
  }
}
