import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../interceptors/auth_interceptor.dart';
import '../../routes/app_routes.dart';

class ApiClient {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.apiUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {"Content-Type": "application/json"},
          ),
        )
        ..interceptors.add(AuthInterceptor(onSessionExpired: _forceLogin))
        ..interceptors.add(
          LogInterceptor(requestBody: true, responseBody: true),
        );

  static void setToken(String token) {
    dio.options.headers["Authorization"] = "Bearer $token";
  }

  static void clearToken() {
    dio.options.headers.remove("Authorization");
  }

  static Future<void> _forceLogin() async {
    clearToken();

    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
