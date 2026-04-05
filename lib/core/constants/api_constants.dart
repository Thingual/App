class ApiConstants {
  /// Base URL for the backend - Always use Render backend for all modes
  ///
  /// Priority:
  /// 1) `--dart-define=API_BASE_URL=...` (override)
  /// 2) Render backend (all modes)
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    // Always use Render backend, no distinction between debug/release
    return 'https://thingual-backend.onrender.com';
  }

  // Auth endpoints
  static const String signupEndpoint = '/auth/email/signup';
  static const String loginEndpoint = '/auth/email/login';
  static const String googleAuthEndpoint = '/auth/google/login';

  // Phone auth endpoints
  static const String phoneSignupEndpoint = '/auth/phone/request-otp';
  static const String phoneLoginEndpoint = '/auth/phone/verify-otp';

  // Listening assessment
  static const String listeningTranscribeEndpoint =
      '/assessment/listening/transcribe';

  // Storage keys
  static const String tokenKey = 'jwt_token';
  static const String userEmailKey = 'user_email';
  static const String userPhoneKey = 'user_phone';
}
