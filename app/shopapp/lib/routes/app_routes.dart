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

    admin: (context) => AdminLayout(
      initialRoute: '/admin',
      userId: ModalRoute.of(context)!.settings.arguments as int? ?? 0,
    ),

    adminProducts: (context) => AdminLayout(
      initialRoute: '/admin/products',
      userId: ModalRoute.of(context)!.settings.arguments as int? ?? 0,
    ),
  };

  static var home;
}