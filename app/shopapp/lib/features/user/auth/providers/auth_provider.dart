import 'package:flutter/material.dart';
import '../../../../services/auth/social_auth_service.dart';
import '../../../../repositories/interfaces/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository repo;
  final SocialAuthService social;

  bool loading = false;
  String? accessToken;
  String? error;

  AuthProvider(this.repo, this.social);

  bool get isLoggedIn => accessToken != null;

  Future<void> loginGoogle() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final token = await social.loginGoogle();

      if (token == null) {
        error = "Google login cancelled";
        return;
      }

      final res = await repo.socialLogin(provider: "google", token: token);

      accessToken = res['accessToken'];
    } catch (e) {
      error = "Login failed";
      print(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loginFacebook() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final token = await social.loginFacebook();

      if (token == null) {
        error = "Facebook login cancelled";
        return;
      }

      final res = await repo.socialLogin(provider: "facebook", token: token);

      accessToken = res['accessToken'];
    } catch (e) {
      error = "Login failed";
      print(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
