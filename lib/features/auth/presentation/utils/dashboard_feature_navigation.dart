import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_features.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_id.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/grind_calibration_page.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_sessions_page.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/defect_library_page.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/cost_management_page.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/inventory_page.dart';
import 'package:cafelab_iot_mobile/features/preparation/presentation/preparation_test_page.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/presentation/coffee_lots_page.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/roast_profiles_page.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/presentation/suppliers_page.dart';
import 'package:flutter/material.dart';

abstract final class DashboardFeatureNavigation {
  static void open(
    BuildContext context,
    DashboardFeatureId id, {
    required SubscriptionPlanType planType,
  }) {
    if (!DashboardFeatures.isFeatureAvailable(id, planType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Esta funcionalidad no está disponible en tu plan actual.',
          ),
        ),
      );
      return;
    }

    final route = _routeFor(id, planType: planType);
    if (route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Monitoreo — próximamente en la app móvil.'),
        ),
      );
      return;
    }

    Navigator.of(context).push(route);
  }

  static Route<void>? _routeFor(
    DashboardFeatureId id, {
    required SubscriptionPlanType planType,
  }) {
    return switch (id) {
      DashboardFeatureId.cuppingSessions => MaterialPageRoute<void>(
          builder: (_) => CuppingSessionsPage(planType: planType),
        ),
      DashboardFeatureId.defectLibrary => MaterialPageRoute<void>(
          builder: (_) => DefectLibraryPage(planType: planType),
        ),
      DashboardFeatureId.grindCalibration => MaterialPageRoute<void>(
          builder: (_) => GrindCalibrationPage(planType: planType),
        ),
      DashboardFeatureId.recipes => MaterialPageRoute<void>(
          builder: (_) => const PreparationTestPage(),
        ),
      DashboardFeatureId.monitoring => null,
      DashboardFeatureId.suppliers => MaterialPageRoute<void>(
          builder: (_) => const SuppliersPage(),
        ),
      DashboardFeatureId.coffeeLots => MaterialPageRoute<void>(
          builder: (_) => const CoffeeLotsPage(),
        ),
      DashboardFeatureId.roastProfiles => MaterialPageRoute<void>(
          builder: (_) => const RoastProfilesPage(),
        ),
      DashboardFeatureId.inventory => MaterialPageRoute<void>(
          builder: (_) => const InventoryPage(),
        ),
      DashboardFeatureId.productionCost => MaterialPageRoute<void>(
          builder: (_) => CostManagementPage(planType: planType),
        ),
    };
  }
}
