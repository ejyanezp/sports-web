class EnvConfig {
  // Leemos las variables del sistema. Si no existen, usamos valores de desarrollo.
  static const String clientId = String.fromEnvironment('COGNITO_CLIENT_ID', defaultValue: '');
  static const String cognitoDomain = String.fromEnvironment('COGNITO_DOMAIN', defaultValue: '');
  static const String redirectUri = String.fromEnvironment('REDIRECT_URI', defaultValue: 'http://localhost:8088/');
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Validación de seguridad para desarrollo
  static void validate() {
    if (clientId.isEmpty || cognitoDomain.isEmpty || redirectUri.isEmpty) {
      throw Exception("Faltan variables de entorno. Asegúrate de usar --dart-define para: "
        "COGNITO_CLIENT_ID, COGNITO_DOMAIN y REDIRECT_URI"
      );
    }
  }
}