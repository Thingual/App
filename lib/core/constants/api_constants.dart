class ApiConstants {
  // IMPORTANT: For physical devices, both devices must be on the same WiFi network
  // Set to your PC's local network IP address
  static const String baseUrl = 'http://172.19.48.149:8002';

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
