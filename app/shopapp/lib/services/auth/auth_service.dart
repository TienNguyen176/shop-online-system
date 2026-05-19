import '../../core/api/api_client.dart';
import 'package:dio/dio.dart';

class AuthService {
  /// ===== LOGIN SOCIAL =====
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    final res = await ApiClient.dio.post(
      "/api/auth/social-login",
      data: {"provider": provider, "token": token},
    );

    return res.data;
  }

  /// ===== CURRENT USER =====
  Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await ApiClient.dio.get("/api/auth/me");

    return Map<String, dynamic>.from(res.data);
  }

  /// ===== UPDATE PROFILE =====
  /// UPDATE PROFILE (UPLOAD FILE)
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? avatarPath,
  }) async {
    final formData = FormData.fromMap({
      "fullName": fullName,
      if (avatarPath != null)
        "avatar": await MultipartFile.fromFile(avatarPath),
    });

    final res = await ApiClient.dio.put("/api/profile", data: formData);

    return res.data;
  }
}
