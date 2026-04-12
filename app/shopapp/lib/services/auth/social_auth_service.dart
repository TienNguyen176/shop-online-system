import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SocialAuthService {
  /// ===== GOOGLE LOGIN =====
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId:
        "666877172796-cba34lb94j9c7rivvhgu9or68e4nkb1u.apps.googleusercontent.com",
  );

  Future<String?> loginGoogle() async {
    try {
      final account = await _googleSignIn.signIn();

      print("ACCOUNT: $account");

      if (account == null) return null;

      final auth = await account.authentication;

      print("ID TOKEN: ${auth.idToken}");
      
      print("ACCESS TOKEN: ${auth.accessToken}");

      print(_googleSignIn);

      return auth.idToken;
    } catch (e) {
      print("Google login error: $e");
      return null;
    }
  }

  /// ===== FACEBOOK LOGIN =====
  Future<String?> loginFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) return null;

      return result.accessToken?.tokenString;
    } catch (e) {
      print("Facebook login error: $e");
      return null;
    }
  }

  /// ===== LOGOUT =====
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
  }
}
