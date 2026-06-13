import 'package:cafelab_iot_mobile/features/production/coffee_lots/presentation/coffee_lots_page.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/roast_profiles_page.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/presentation/suppliers_page.dart';
import 'package:flutter/material.dart';

class ProductionHomePage extends StatelessWidget {
  const ProductionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modulo de Produccion')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_fire_department_outlined),
              title: const Text('Perfiles de tueste'),
              subtitle: const Text('Listado, detalle y comparacion'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RoastProfilesPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.coffee_outlined),
              title: const Text('Lotes de cafe'),
              subtitle: const Text('Listado, detalle y mantenimiento'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CoffeeLotsPage()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_shipping_outlined),
              title: const Text('Proveedores'),
              subtitle: const Text('Listado, detalle y mantenimiento'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SuppliersPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
