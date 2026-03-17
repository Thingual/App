import 'user_model.dart';

/// Matches backend `TokenResponse` JSON shape.
class AuthResponse {
  final String accessToken;
  final String tokenType;
  final String? refreshToken;
  final int? expiresIn;
  final UserModel? user;

  AuthResponse({
    required this.accessToken,
    required this.tokenType,
    this.refreshToken,
    this.expiresIn,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      tokenType: json['token_type'] ?? 'bearer',
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
