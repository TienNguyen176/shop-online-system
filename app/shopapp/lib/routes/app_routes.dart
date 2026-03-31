import 'package:flutter/material.dart';

import '../features/admin/layout/admin_layout.dart';
import '../features/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const admin = '/admin';
  static const adminProducts = '/admin/products';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),

    admin: (context) => const AdminLayout(initialRoute: '/admin'),

    adminProducts:
        (context) => const AdminLayout(initialRoute: '/admin/products'),
  };
}
