import '../interfaces/i_auth_repository.dart';
import '../../services/auth/auth_service.dart';
import 'package:shopapp/core/api/api_client.dart';

class AuthRepository implements IAuthRepository {
  final AuthService service = AuthService();

  Map<String, dynamic>? _cache;
  String? _token;

  @override
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    final data = await service.socialLogin(provider: provider, token: token);

    _cache = data['user'];
    _token = data['accessToken'];

    if (_token != null) {
      ApiClient.setToken(_token!);
    }

    return data;
  }

  @override
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? avatarPath,
  }) async {
    final data = await service.updateProfile(
      fullName: fullName,
      avatarPath: avatarPath,
    );

    _cache = data;

    return data;
  }

  @override
  String? getToken() {
    return _token;
  }

  @override
  Map<String, dynamic>? getCurrentUser() => _cache;

  @override
  void logout() {
    _cache = null;
    _token = null;
    ApiClient.dio.options.headers.remove("Authorization");
  }
}
