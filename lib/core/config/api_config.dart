class ApiConfig {
  static const String _azureBackendUrl =
      'https://cafelabbackend-gmg8egarcxadh4ec.canadacentral-01.azurewebsites.net';

  // Override at run time: --dart-define=API_BASE_URL=http://10.0.2.2:8080
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _azureBackendUrl,
  );

  static const String authBasePath = '/api/v1/authentication';
  static const String supplierBasePath = '/api/v1/suppliers';
  static const String coffeeLotsBasePath = '/api/v1/coffee-lots';
  static const String roastProfilesBasePath = '/api/v1/roast-profile';
  static const String inventoryEntriesBasePath = '/api/v1/inventory-entries';
  static const String cuppingSessionsBasePath = '/api/v1/cupping-sessions';
  static const String monitoringBasePath = '/api/v1/environment-thresholds';
}
