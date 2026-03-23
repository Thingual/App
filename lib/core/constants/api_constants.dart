import 'package:flutter/foundation.dart';

class ApiConstants {
  /// Base URL for the backend.
  ///
  /// Priority:
  /// 1) `--dart-define=API_BASE_URL=...`
  /// 2) Debug/dev default to local backend (platform-aware)
  /// 3) Release default to deployed Render backend
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;

    if (kReleaseMode) {
      return 'https://thingual-backend.onrender.com';
    }

    // Dev defaults
    if (kIsWeb) return 'http://localhost:8002';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator host loopback
        return 'http://10.0.2.2:8002';
      case TargetPlatform.iOS:
        return 'http://localhost:8002';
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return 'http://127.0.0.1:8002';
      case TargetPlatform.fuchsia:
        return 'http://127.0.0.1:8002';
    }
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
