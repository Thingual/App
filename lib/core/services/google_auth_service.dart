import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;

  // Use Web Client ID for serverClientId to get ID token
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '309791423651-665cmmjv40belljta53s9eep01tm1f7h.apps.googleusercontent.com',
  );

  GoogleAuthService._internal();

  /// Sign in with Google
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Sign out first to ensure account picker is shown
      await _googleSignIn.signOut();
      return await _googleSignIn.signIn();
    } catch (e) {
      rethrow;
    }
  }

  /// Get ID token from Google account
  Future<String?> getIdToken(GoogleSignInAccount account) async {
    try {
      final authentication = await account.authentication;
      return authentication.idToken;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
