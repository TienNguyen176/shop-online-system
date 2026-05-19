import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../core/config/app_config.dart';

class SocialAuthService {
  /// ===== GOOGLE LOGIN =====
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
    serverClientId: AppConfig.googleServerClientId,
  );

  Future<String?> loginGoogle() async {
    try {
      final account = await _googleSignIn.signIn();

      //print("ACCOUNT: $account");

      if (account == null) return null;

      final auth = await account.authentication;

      //print("ID TOKEN: ${auth.idToken}");

      //print("ACCESS TOKEN: ${auth.accessToken}");

      //print(_googleSignIn);

      return auth.idToken;
    } catch (e) {
      debugPrint("Google login error: $e");
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
      debugPrint("Facebook login error: $e");
      return null;
    }
  }

  /// ===== LOGOUT =====
  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("Google logout error: $e");
    }

    try {
      await FacebookAuth.instance.logOut();
    } catch (e) {
      debugPrint("Facebook logout error: $e");
    }
  }
}
