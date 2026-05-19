import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/api/api_client.dart';
import '../../../../repositories/interfaces/i_auth_repository.dart';
import '../../../../services/auth/social_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository repo;
  final SocialAuthService social;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool loading = false;
  bool restoring = false;
  String? accessToken;
  String? refreshToken;
  String? error;

  Map<String, dynamic>? user;

  AuthProvider(this.repo, this.social);

  bool get isLoggedIn => accessToken != null;

  static const _tokenKey = "token";
  static const _refreshTokenKey = "refresh_token";
  static const _userKey = "user";

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
      await _setSession(res);
    } catch (e) {
      error = "Login failed";
      debugPrint(e.toString());
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
      await _setSession(res);
    } catch (e) {
      error = "Login failed";
      debugPrint(e.toString());
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    try {
      restoring = true;
      error = null;
      notifyListeners();

      final token = await _storage.read(key: _tokenKey);
      final refresh = await _storage.read(key: _refreshTokenKey);
      final userJson = await _storage.read(key: _userKey);

      if (token == null ||
          token.isEmpty ||
          userJson == null ||
          userJson.isEmpty) {
        accessToken = null;
        refreshToken = null;
        user = null;
        return;
      }

      accessToken = token;
      refreshToken = refresh;
      user = Map<String, dynamic>.from(jsonDecode(userJson));
      ApiClient.setToken(token);
    } catch (e) {
      debugPrint("Restore session error: $e");
      await logout();
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

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

      user = res;
      await _saveSession();
    } catch (e) {
      debugPrint("Update profile error: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
    repo.logout();

    accessToken = null;
    refreshToken = null;
    user = null;
    error = null;
    loading = false;
    restoring = false;
    notifyListeners();

    await social.logout();
  }

  Future<void> _setSession(Map<String, dynamic> res) async {
    accessToken = res["accessToken"];
    refreshToken = res["refreshToken"];
    user = Map<String, dynamic>.from(res["user"] ?? {});
    await _saveSession();
  }

  Future<void> _saveSession() async {
    if (accessToken != null && accessToken!.isNotEmpty) {
      await _storage.write(key: _tokenKey, value: accessToken);
      ApiClient.setToken(accessToken!);
    }

    if (refreshToken != null && refreshToken!.isNotEmpty) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }

    if (user != null) {
      await _storage.write(key: _userKey, value: jsonEncode(user));
    }
  }
}
