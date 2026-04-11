import '../interfaces/i_auth_repository.dart';
import '../../services/auth/auth_service.dart';

class AuthRepository implements IAuthRepository {
  final AuthService service = AuthService();

  Map<String, dynamic>? _cache; // optional (nếu muốn cache user)

  @override
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    final data = await service.socialLogin(provider: provider, token: token);

    _cache = data; // lưu lại nếu cần

    return data;
  }
}
