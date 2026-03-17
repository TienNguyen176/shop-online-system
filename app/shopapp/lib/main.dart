import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/splash_screen.dart';
import 'repositories/product_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/i_product_repository.dart';
import 'repositories/i_category_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Inject repo global (simple DI)
    final IProductRepository productRepo = ProductRepository();
    final ICategoryRepository categoryRepo = CategoryRepository();

    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xffeef2fb),
      ),

      /// Route
      home: SplashScreen(productRepo: productRepo, categoryRepo: categoryRepo),
    );
  }
}
