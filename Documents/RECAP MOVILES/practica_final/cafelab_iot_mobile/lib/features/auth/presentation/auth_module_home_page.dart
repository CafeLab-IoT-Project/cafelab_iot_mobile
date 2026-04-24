import 'package:cafelab_iot_mobile/features/auth/presentation/auth_test_page.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/defects_test_page.dart';
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
        ],
      ),
    );
  }
}
