class ApiConfig {
  // Override with: --dart-define=API_BASE_URL=http://<your-laptop-ip>:5000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5000',
  );
}
