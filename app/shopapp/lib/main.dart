import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'features/user/auth/providers/auth_provider.dart';

import 'features/admin/attribute/providers/attribute_provider.dart';
import 'features/user/payment/providers/payment_provider.dart';
import 'features/user/notification/providers/notification_provider.dart';
import 'features/user/product/providers/product_detail_provider.dart';
import 'repositories/impl/attribute_repository.dart';
import 'repositories/impl/payment_repository.dart';
import 'repositories/impl/product_admin_repository.dart';
import 'repositories/impl/product_repository.dart';
import 'repositories/impl/category_repository.dart';
import 'repositories/impl/auth_repository.dart';
import 'repositories/impl/cart_repository.dart';
import 'repositories/impl/order_repository.dart';
import 'repositories/impl/statistic_repository.dart';

import 'repositories/interfaces/i_product_repository.dart';
import 'repositories/interfaces/i_category_repository.dart';

import 'features/user/home/providers/home_provider.dart';
import 'features/admin/category/providers/category_provider.dart';
import 'features/admin/dashboard/providers/dashboard_provider.dart';
import 'features/admin/product/providers/product_admin_provider.dart';
import 'features/user/cart/providers/cart_provider.dart';
import 'features/user/order_status/providers/order_status_provider.dart';

import 'services/auth/social_auth_service.dart';

import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final authRepo = AuthRepository();
  final productRepo = ProductRepository();
  final categoryRepo = CategoryRepository();
  final attributeRepo = AttributeRepository();
  final adminProductRepo = ProductAdminRepository();

  final cartRepo = CartRepository();
  final orderRepo = OrderRepository();
  final paymentRepo = PaymentRepository();
  final statisticRepo = StatisticRepository();

  runApp(
    MultiProvider(
      providers: [
        /// GLOBAL REPO
        Provider<IProductRepository>.value(value: productRepo),
        Provider<ICategoryRepository>.value(value: categoryRepo),

        /// FEATURE PROVIDER
        /// HOME SCREEN
        ChangeNotifierProvider(create: (_) => HomeProvider(productRepo)),

        /// PRODUCT DETAIL SCREEN
        ChangeNotifierProvider(
          create: (_) => ProductDetailProvider(productRepo),
        ),

        /// CART SCREEN
        ChangeNotifierProvider(create: (_) => CartProvider(cartRepo)),

        /// ORDER STATUS SCREEN
        ChangeNotifierProvider(create: (_) => OrderStatusProvider(orderRepo)),

        /// PAYMENT SCREEN
        ChangeNotifierProvider(create: (_) => PaymentProvider(paymentRepo)),

        /// NOTIFICATION SCREEN
        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        /// ADMIN DASHBOARD
        ChangeNotifierProvider(create: (_) => DashboardProvider(statisticRepo)),

        /// ADMIN CATEGORY
        ChangeNotifierProvider(
          create:
              (context) =>
                  CategoryProvider(context.read<ICategoryRepository>())
                    ..loadCategories(),
        ),

        /// ADMIN ATTRIBUTE
        ChangeNotifierProvider(create: (_) => AttributeProvider(attributeRepo)),

        /// ADMIN PRODUCT
        ChangeNotifierProvider(
          create: (_) => ProductAdminProvider(adminProductRepo),
        ),

        /// AUTH
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo, SocialAuthService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xffeef2fb),
      ),

      // ROUTES SYSTEM
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
