import 'package:flutter/material.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/auth_module_home_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CafeLab IoT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthModuleHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
