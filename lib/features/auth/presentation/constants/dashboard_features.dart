import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_item.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';

abstract final class DashboardFeatures {
  static const barista = [
    DashboardFeatureItem(
      title: 'Sesiones de cata',
      imageAsset: DashboardAssets.catas,
    ),
    DashboardFeatureItem(
      title: 'Librería de defectos',
      imageAsset: DashboardAssets.defects,
    ),
    DashboardFeatureItem(
      title: 'Calibración de molienda',
      imageAsset: DashboardAssets.calibracion,
    ),
    DashboardFeatureItem(
      title: 'Recetas',
      imageAsset: DashboardAssets.recetas,
    ),
    DashboardFeatureItem(
      title: 'Monitoreo',
      imageAsset: DashboardAssets.monitoreo,
    ),
  ];

  static const owner = [
    DashboardFeatureItem(
      title: 'Proveedores',
      imageAsset: DashboardAssets.suppliers,
    ),
    DashboardFeatureItem(
      title: 'Lotes de café',
      imageAsset: DashboardAssets.lots,
    ),
    DashboardFeatureItem(
      title: 'Perfiles de tueste',
      imageAsset: DashboardAssets.roastProfiles,
    ),
    DashboardFeatureItem(
      title: 'Inventario',
      imageAsset: DashboardAssets.inventario,
    ),
    DashboardFeatureItem(
      title: 'Gestión de costos',
      imageAsset: DashboardAssets.costos,
    ),
    DashboardFeatureItem(
      title: 'Monitoreo',
      imageAsset: DashboardAssets.monitoreo,
    ),
  ];

  static const full = [
    ...barista,
    ...owner,
  ];

  static List<DashboardFeatureItem> forPlanType(SubscriptionPlanType type) {
    return switch (type) {
      SubscriptionPlanType.barista => barista,
      SubscriptionPlanType.owner => owner,
      SubscriptionPlanType.full => full,
    };
  }

  static SubscriptionPlanType planTypeFromApi(String plan) {
    final normalized = plan.toLowerCase();
    if (normalized.contains('owner')) return SubscriptionPlanType.owner;
    if (normalized.contains('full')) return SubscriptionPlanType.full;
    return SubscriptionPlanType.barista;
  }
}
