import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Future<void> Function()? onSessionExpired;
  final storage = const FlutterSecureStorage();
  Future<String?>? _refreshingToken;

  AuthInterceptor({this.onSessionExpired});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    String? token = await storage.read(key: "token");

    if (token != null && token.isNotEmpty) {
      options.headers["Authorization"] = "Bearer $token";
    } else {
      options.headers.remove("Authorization");
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;
    final isAuthEndpoint =
        path.contains("/api/auth/") && !path.contains("/api/auth/me");

    if (statusCode != 401 || isAuthEndpoint) {
      return handler.next(err);
    }

    try {
      final newToken = await (_refreshingToken ??= _refreshAccessToken(err));
      _refreshingToken = null;

      if (newToken == null || newToken.isEmpty) {
        await _clearSession();
        return handler.next(_sessionExpiredError(err));
      }

      final request = err.requestOptions;
      request.headers["Authorization"] = "Bearer $newToken";

      final response = await Dio().fetch(request);
      return handler.resolve(response);
    } catch (_) {
      _refreshingToken = null;
      await _clearSession();
      return handler.next(_sessionExpiredError(err));
    }
  }

  Future<String?> _refreshAccessToken(DioException err) async {
    final refreshToken = await storage.read(key: "refresh_token");
    if (refreshToken == null || refreshToken.isEmpty) return null;

    final dio = Dio(
      BaseOptions(
        baseUrl: err.requestOptions.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    final res = await dio.post(
      "/api/auth/refresh",
      data: {"refreshToken": refreshToken},
    );

    final accessToken = res.data["accessToken"]?.toString();
    final newRefreshToken = res.data["refreshToken"]?.toString();

    if (accessToken == null || accessToken.isEmpty) return null;

    await storage.write(key: "token", value: accessToken);

    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await storage.write(key: "refresh_token", value: newRefreshToken);
    }

    return accessToken;
  }

  Future<void> _clearSession() async {
    await storage.delete(key: "token");
    await storage.delete(key: "refresh_token");
    await storage.delete(key: "user");
    await onSessionExpired?.call();
  }

  DioException _sessionExpiredError(DioException err) {
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.",
    );
  }
}
