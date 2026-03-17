import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../interceptors/auth_interceptor.dart';

class ApiClient {
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.apiUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {"Content-Type": "application/json"},
          ),
        )
        ..interceptors.add(AuthInterceptor())
        ..interceptors.add(
          LogInterceptor(requestBody: true, responseBody: true),
        );
}
