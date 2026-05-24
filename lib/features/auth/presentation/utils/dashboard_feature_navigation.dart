import 'package:cafelab_iot_mobile/features/auth/presentation/models/dashboard_feature_id.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/calibrations_test_page.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_sessions_test_page.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/defects_test_page.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/management_test_page.dart';
import 'package:cafelab_iot_mobile/features/preparation/presentation/preparation_test_page.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/presentation/coffee_lots_page.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/roast_profiles_page.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/presentation/suppliers_page.dart';
import 'package:flutter/material.dart';

abstract final class DashboardFeatureNavigation {
  static void open(BuildContext context, DashboardFeatureId id) {
    final route = _routeFor(id);
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

  static Route<void>? _routeFor(DashboardFeatureId id) {
    return switch (id) {
      DashboardFeatureId.cuppingSessions => MaterialPageRoute<void>(
          builder: (_) => const CuppingSessionsTestPage(),
        ),
      DashboardFeatureId.defectLibrary => MaterialPageRoute<void>(
          builder: (_) => const DefectsTestPage(),
        ),
      DashboardFeatureId.grindCalibration => MaterialPageRoute<void>(
          builder: (_) => const CalibrationsTestPage(),
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
          builder: (_) => const ManagementTestPage(),
        ),
      DashboardFeatureId.productionCost => MaterialPageRoute<void>(
          builder: (_) => const ManagementTestPage(),
        ),
    };
  }
}
