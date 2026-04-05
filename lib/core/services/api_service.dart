import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import 'auth_service.dart';

void _log(String message, {bool isError = false}) {
  if (kDebugMode) {
    if (isError) {
      print('❌ API ERROR: $message');
    } else {
      print('📡 API: $message');
    }
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final AuthService _authService = AuthService();

  ApiService._internal() {
    _initializeDio();
  }

  /// Initialize or reinitialize the Dio client
  void _initializeDio() {
    final baseUrl = ApiConstants.baseUrl;
    _log('Initializing API Service');
    _log('Base URL: $baseUrl');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        // Fail fast if the backend isn't reachable, but still allow slower responses.
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  /// Call this when the app resumes from background
  /// to reset the connection
  void refreshConnection() {
    _initializeDio();
  }

  /// Sign up with email and password
  Future<AuthResponse> signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.signupEndpoint,
        data: {'email': email, 'password': password},
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      _log('Starting login for: $email');
      _log('Endpoint: ${ApiConstants.loginEndpoint}');

      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      _log('Login response received: ${response.statusCode}');
      final authResponse = AuthResponse.fromJson(response.data);
      await _authService.saveToken(authResponse.accessToken);
      await _authService.saveUserEmail(email);
      _log('Login successful!');
      return authResponse;
    } on DioException catch (e) {
      _log('Login request failed', isError: true);
      throw _handleError(e);
    }
  }

  /// Google Sign-In
  Future<AuthResponse> googleSignIn({required String idToken}) async {
    try {
      final response = await _dio.post(
        ApiConstants.googleAuthEndpoint,
        data: {'google_id_token': idToken},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _authService.saveToken(authResponse.accessToken);
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Transcribe an audio file (recorded from mic) for the listening assessment.
  ///
  /// Expects the backend to run Whisper and return: `{ "text": "..." }`.
  Future<String> transcribeListeningAudio({
    required String filePath,
    String? filename,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: filename),
      });

      final response = await _dio.post(
        ApiConstants.listeningTranscribeEndpoint,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['text'] is String) {
        return data['text'] as String;
      }
      if (data is Map && data['text'] is String) {
        return data['text'] as String;
      }

      throw 'Unexpected transcription response format.';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign up with phone number and password
  Future<void> phoneSignup({
    required String phoneNumber,
    required String password,
  }) async {
    throw 'Phone auth is not supported by the current backend schema. Use Email.';
  }

  /// Login with phone number and password
  Future<AuthResponse> phoneLogin({
    required String phoneNumber,
    required String password,
  }) async {
    throw 'Phone auth is not supported by the current backend schema. Use Email.';
  }

  String _handleError(DioException e) {
    String errorMsg = '';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMsg =
            'Connection timeout (10s). Backend may be unreachable at ${ApiConstants.baseUrl}';
        _log('Connection timeout to: ${ApiConstants.baseUrl}', isError: true);
      case DioExceptionType.sendTimeout:
        errorMsg = 'Send timeout (30s). Check network and backend.';
        _log('Send timeout', isError: true);
      case DioExceptionType.receiveTimeout:
        errorMsg = 'Receive timeout (60s). Backend response too slow.';
        _log('Receive timeout', isError: true);
      case DioExceptionType.connectionError:
        errorMsg =
            'Connection error. Cannot reach ${ApiConstants.baseUrl}. Is the backend running?';
        _log('Connection error to: ${ApiConstants.baseUrl}', isError: true);
      case DioExceptionType.badCertificate:
        errorMsg = 'Bad SSL certificate.';
      case DioExceptionType.cancel:
        errorMsg = 'Request cancelled.';
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        break;
    }

    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        errorMsg = data['detail'];
      } else {
        errorMsg = 'Error: ${e.response?.statusCode}';
      }
    }

    final finalMsg = errorMsg.isNotEmpty
        ? errorMsg
        : (e.message ?? 'Network error occurred');
    _log('Final error: $finalMsg', isError: true);
    _log('Base URL was: ${ApiConstants.baseUrl}', isError: true);
    return finalMsg;
  }
}
