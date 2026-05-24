import 'package:cafelab_iot_mobile/features/auth/presentation/auth_test_page.dart';
import 'package:cafelab_iot_mobile/features/calibrations/presentation/calibrations_test_page.dart';
import 'package:cafelab_iot_mobile/features/coffees/presentation/coffees_test_page.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_sessions_test_page.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/defects_test_page.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/management_test_page.dart';
import 'package:cafelab_iot_mobile/features/preparation/presentation/preparation_test_page.dart';
import 'package:cafelab_iot_mobile/features/production/presentation/production_home_page.dart';
import 'package:flutter/material.dart';

class AuthModuleHomePage extends StatelessWidget {
  const AuthModuleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Module Test Home')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Management'),
              subtitle: const Text('Inventory entries CRUD'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ManagementTestPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restaurant_menu_outlined),
              title: const Text('Preparation'),
              subtitle: const Text('Portfolios + Recipes + Ingredients'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PreparationTestPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.tune_outlined),
              title: const Text('Calibrations'),
              subtitle: const Text('Create/List/Get/Update (sin DELETE)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CalibrationsTestPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Auth'),
              subtitle: const Text('Sign-in / Sign-up integration test'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AuthTestPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_drink_outlined),
              title: const Text('Cupping sessions'),
              subtitle: const Text('CRUD integration test'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CuppingSessionsTestPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.coffee_outlined),
              title: const Text('Coffees'),
              subtitle: const Text('Create/List/Get by id integration test'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CoffeesTestPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Defects'),
              subtitle: const Text('Create/List/Get by id integration test'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DefectsTestPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.precision_manufacturing_outlined),
              title: const Text('Production'),
              subtitle: const Text('Roast Profiles + Coffee Lots'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProductionHomePage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
