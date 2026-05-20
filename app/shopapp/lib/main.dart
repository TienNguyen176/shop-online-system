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
import 'features/admin/order/providers/admin_order_provider.dart';
import 'features/admin/product/providers/product_admin_provider.dart';
import 'features/user/cart/providers/cart_provider.dart';
import 'features/user/order_status/providers/order_status_provider.dart';

import 'services/admin_order_service.dart';
import 'services/auth/social_auth_service.dart';
import 'core/api/api_client.dart';
import 'core/permissions/app_permission_service.dart';

import 'routes/app_routes.dart';

/// Khoi tao ung dung va cau hinh cac provider can thiet.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await const AppPermissionService().requestStartupPermissions();

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

        /// ADMIN ORDER
        ChangeNotifierProvider(
          create: (_) => AdminOrderProvider(AdminOrderService()),
        ),

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

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next4Shop',
      debugShowCheckedModeBanner: false,
      navigatorKey: ApiClient.navigatorKey,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamilyFallback: const ["Roboto", "Arial", "Noto Sans"],
        scaffoldBackgroundColor: const Color(0xffeef2fb),
      ),

      // ROUTES SYSTEM
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
