import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/auth_response.dart';
import 'auth_service.dart';

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
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
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
      final response = await _dio.post(
        ApiConstants.loginEndpoint,
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _authService.saveToken(authResponse.accessToken);
      await _authService.saveUserEmail(email);
      return authResponse;
    } on DioException catch (e) {
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
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Check that the backend is running and reachable.';
      case DioExceptionType.connectionError:
        return 'Could not connect to server. Check the backend URL and that the server is running.';
      case DioExceptionType.badCertificate:
        return 'Bad SSL certificate.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.unknown:
      case DioExceptionType.badResponse:
        break;
    }

    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map<String, dynamic> && data.containsKey('detail')) {
        return data['detail'];
      }
      return 'Error: ${e.response?.statusCode}';
    }
    return e.message ?? 'Network error occurred';
  }
}
