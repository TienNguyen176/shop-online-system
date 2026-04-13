import 'package:flutter/material.dart';
import '../features/user/auth/screens/login_screen.dart';
import '../features/admin/layout/admin_layout.dart';
import '../features/splash_screen.dart';
import '../features/user/home/screens/home_screen.dart';
import '../features/user/profile/screens/profile_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const admin = '/admin';
  static const adminProducts = '/admin/products';
  static const login = '/login';
  static const userHome = '/home';
  static const profile = '/profile';
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),

    admin: (context) => const AdminLayout(initialRoute: '/admin'),

    login: (context) => const LoginScreen(),

    adminProducts:
        (context) => const AdminLayout(initialRoute: '/admin/products'),

    userHome: (context) => const HomeScreen(),

    profile: (context) => const ProfileScreen(),
  };
}
