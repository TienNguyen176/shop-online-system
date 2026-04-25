import 'package:flutter/material.dart';
import '../features/user/home/screens/home_screen.dart';
import '../features/user/auth/screens/login_screen.dart';
import '../features/admin/layout/admin_layout.dart';
import '../features/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const userHome = '/home';
  static const userProfile = '/profile';
  static const admin = '/admin';
  static const adminProducts = '/admin/products';

  static Map<String, WidgetBuilder> routes = {

    splash: (context) => const SplashScreen(),

    login: (context) => const LoginScreen(),

    userHome: (context) => const HomeScreen(),

    //userProfile: (context) => const ProfileScreen(),

    admin: (context) => const AdminLayout(initialRoute: '/admin'),

    adminProducts:
        (context) => const AdminLayout(initialRoute: '/admin/products'),
  };

  static var home;
}
