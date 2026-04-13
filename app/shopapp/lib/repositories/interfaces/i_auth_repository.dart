abstract class IAuthRepository {
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  });

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? avatarPath,
  });

  Map<String, dynamic>? getCurrentUser();

  String? getToken();

  void logout();
}
