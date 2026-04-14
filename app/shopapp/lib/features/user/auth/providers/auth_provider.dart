import 'package:flutter/material.dart';
import '../../../../services/auth/social_auth_service.dart';
import '../../../../repositories/interfaces/i_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository repo;
  final SocialAuthService social;

  bool loading = false;
  String? accessToken;
  String? error;

  Map<String, dynamic>? user;

  AuthProvider(this.repo, this.social);

  bool get isLoggedIn => accessToken != null;

  /// ===== GOOGLE LOGIN =====
  Future<void> loginGoogle() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final token = await social.loginGoogle();

      if (token == null) {
        error = "Google login cancelled";
        loading = false;
        notifyListeners();
        return;
      }

      final res = await repo.socialLogin(provider: "google", token: token);

      /// 🔥 FIX QUAN TRỌNG
      accessToken = res['accessToken'];
      user = res['user']; // <-- PHẢI CÓ DÒNG NÀY
    } catch (e) {
      error = "Login failed";
      print(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ===== FACEBOOK LOGIN =====
  Future<void> loginFacebook() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final token = await social.loginFacebook();

      if (token == null) {
        error = "Facebook login cancelled";
        loading = false;
        notifyListeners();
        return;
      }

      final res = await repo.socialLogin(provider: "facebook", token: token);

      /// 🔥 FIX
      accessToken = res['accessToken'];
      user = res['user'];
    } catch (e) {
      error = "Login failed";
      print(e);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// ===== UPDATE PROFILE LOCAL =====
  Future<void> updateProfile({
    required String fullName,
    String? avatarPath,
  }) async {
    try {
      loading = true;
      notifyListeners();

      final res = await repo.updateProfile(
        fullName: fullName,
        avatarPath: avatarPath,
      );

      user = res; // KHÔNG merge nữa
    } catch (e) {
      print("Update profile error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
