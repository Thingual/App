class ApiConstants {
  /// Base URL for the backend.
  ///
  /// Defaults to the deployed Render service.
  /// For local development you can override at build time:
  /// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8002`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://thingual-backend.onrender.com',
  );

  // Auth endpoints
  static const String signupEndpoint = '/auth/email/signup';
  static const String loginEndpoint = '/auth/email/login';
  static const String googleAuthEndpoint = '/auth/google/login';

  // Phone auth endpoints
  static const String phoneSignupEndpoint = '/auth/phone/request-otp';
  static const String phoneLoginEndpoint = '/auth/phone/verify-otp';

  // Storage keys
  static const String tokenKey = 'jwt_token';
  static const String userEmailKey = 'user_email';
  static const String userPhoneKey = 'user_phone';
}
