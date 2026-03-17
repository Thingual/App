import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService._internal();

  /// Save JWT token securely
  Future<void> saveToken(String token) async {
    await _storage.write(key: ApiConstants.tokenKey, value: token);
  }

  /// Get stored JWT token
  Future<String?> getToken() async {
    return await _storage.read(key: ApiConstants.tokenKey);
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: ApiConstants.userEmailKey, value: email);
  }

  /// Get stored user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: ApiConstants.userEmailKey);
  }

  /// Save user phone number
  Future<void> saveUserPhone(String phone) async {
    await _storage.write(key: ApiConstants.userPhoneKey, value: phone);
  }

  /// Get stored user phone number
  Future<String?> getUserPhone() async {
    return await _storage.read(key: ApiConstants.userPhoneKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data (logout)
  Future<void> logout() async {
    await _storage.delete(key: ApiConstants.tokenKey);
    await _storage.delete(key: ApiConstants.userEmailKey);
    await _storage.delete(key: ApiConstants.userPhoneKey);
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
