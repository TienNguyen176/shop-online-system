import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/features/user/auth/providers/auth_provider.dart';

import 'features/admin/attribute/providers/attribute_provider.dart';
import 'features/user/product/providers/product_detail_provider.dart';
import 'repositories/impl/attribute_repository.dart';
import 'repositories/impl/product_admin_repository.dart';
import 'repositories/impl/product_repository.dart';
import 'repositories/impl/category_repository.dart';
import 'repositories/impl/auth_repository.dart';

import 'repositories/interfaces/i_product_repository.dart';
import 'repositories/interfaces/i_category_repository.dart';

import 'features/user/home/providers/home_provider.dart';
import 'features/admin/category/providers/category_provider.dart';
import 'features/admin/product/providers/product_admin_provider.dart';

import 'services/auth/social_auth_service.dart';

import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final productRepo = ProductRepository();
  final categoryRepo = CategoryRepository();
  final attributeRepo = AttributeRepository();
  final adminProductRepo = ProductAdminRepository();
  final authRepo = AuthRepository();
  runApp(
    MultiProvider(
      providers: [
        /// GLOBAL REPO
        Provider<IProductRepository>.value(value: productRepo),
        Provider<ICategoryRepository>.value(value: categoryRepo),

        /// FEATURE PROVIDER
        ChangeNotifierProvider(create: (_) => HomeProvider(productRepo)),

        ChangeNotifierProvider(
          create: (_) => ProductDetailProvider(productRepo),
        ),

        ChangeNotifierProvider(
          create:
              (context) =>
                  CategoryProvider(context.read<ICategoryRepository>())
                    ..loadCategories(),
        ),

        ChangeNotifierProvider(create: (_) => AttributeProvider(attributeRepo)),

        ChangeNotifierProvider(
          create: (_) => ProductAdminProvider(adminProductRepo),
        ),

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
      initialRoute: AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}
