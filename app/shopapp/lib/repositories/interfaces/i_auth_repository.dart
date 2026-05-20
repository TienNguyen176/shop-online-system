abstract class IAuthRepository {
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  });

  /// Cap nhat du lieu thong qua updateProfile.
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? avatarPath,
  });

  /// Lay du lieu cho getCurrentUserFromServer.
  Future<Map<String, dynamic>> getCurrentUserFromServer();

  /// Lay du lieu cho getCurrentUser.
  Map<String, dynamic>? getCurrentUser();

  /// Lay du lieu cho getToken.
  String? getToken();

  /// Dang xuat va xoa phien lam viec hien tai.
  void logout();
}
