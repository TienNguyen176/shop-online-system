import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/api/api_client.dart';
import '../../../../repositories/interfaces/i_auth_repository.dart';
import '../../../../services/auth/social_auth_service.dart';

/// Provider quản lý đăng nhập, phiên người dùng và lưu token bảo mật.
class AuthProvider extends ChangeNotifier {
  final IAuthRepository repo;
  final SocialAuthService social;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Trạng thái xử lý khi đăng nhập/cập nhật hồ sơ.
  bool loading = false;

  /// Trạng thái khôi phục phiên khi app vừa mở.
  bool restoring = false;

  /// Access token dùng cho các API cần xác thực.
  String? accessToken;

  /// Refresh token dùng để xin access token mới khi token cũ hết hạn.
  String? refreshToken;

  /// Lỗi đăng nhập hoặc lỗi phiên hiện tại.
  String? error;

  /// Thông tin user đang đăng nhập.
  Map<String, dynamic>? user;

  AuthProvider(this.repo, this.social);

  /// Kiểm tra người dùng đã có access token hay chưa.
  bool get isLoggedIn => accessToken != null;

  static const _tokenKey = "token";
  static const _refreshTokenKey = "refresh_token";
  static const _userKey = "user";

  /// Đăng nhập bằng Google, gửi token Google về backend để lấy session app.
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

  /// Đăng nhập bằng Facebook, gửi token Facebook về backend để lấy session app.
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

  /// Khôi phục phiên đăng nhập từ secure storage khi app khởi động.
  Future<void> restoreSession() async {
    try {
      restoring = true;
      error = null;
      notifyListeners();

      final token = await _storage.read(key: _tokenKey);
      final refresh = await _storage.read(key: _refreshTokenKey);

      if (token == null || token.isEmpty) {
        accessToken = null;
        refreshToken = null;
        user = null;
        return;
      }

      accessToken = token;
      refreshToken = refresh;
      ApiClient.setToken(token);

      user = await repo.getCurrentUserFromServer();
      await _saveSession();
    } catch (e) {
      debugPrint("Restore session error: $e");
      await logout();
    } finally {
      restoring = false;
      notifyListeners();
    }
  }

  /// Cập nhật thông tin hồ sơ người dùng trên backend.
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

  /// Đăng xuất: xóa token, user local và trạng thái đăng nhập.
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

  /// Gán dữ liệu session từ response login/refresh vào state provider.
  Future<void> _setSession(Map<String, dynamic> res) async {
    accessToken = res["accessToken"];
    refreshToken = res["refreshToken"];
    user = Map<String, dynamic>.from(res["user"] ?? {});
    await _saveSession();
  }

  /// Lưu access token, refresh token và user vào secure storage.
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
