import 'package:flutter/foundation.dart';

class ApiConfig {
  // Android emulator -> http://10.0.2.2:8080
  // iOS simulator -> http://localhost:8080
  // Physical device -> http://<LAN_IP_OF_YOUR_PC>:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kIsWeb ? 'http://localhost:8080' : 'http://10.0.2.2:8080',
  );

  static const String authBasePath = '/api/v1/authentication';
  static const String supplierBasePath = '/api/v1/suppliers';
  static const String coffeeLotsBasePath = '/api/v1/coffee-lots';
  static const String roastProfilesBasePath = '/api/v1/roast-profile';
  static const String inventoryEntriesBasePath = '/api/v1/inventory-entries';
}
