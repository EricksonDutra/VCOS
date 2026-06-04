class ApiConfig {
  const ApiConfig({
    this.baseUrl = const String.fromEnvironment(
      'VCOS_API_BASE_URL',
      defaultValue: 'http://localhost:8000/api/v1',
    ),
  });

  final String baseUrl;
}
