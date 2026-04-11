abstract class IAuthRepository {
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  });
}
