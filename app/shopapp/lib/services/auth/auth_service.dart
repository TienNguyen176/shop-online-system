import '../../core/api/api_client.dart';

class AuthService {
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
}
