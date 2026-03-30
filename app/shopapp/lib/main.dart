import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';

import 'repositories/impl/product_repository.dart';
import 'repositories/impl/category_repository.dart';

import 'repositories/interfaces/i_product_repository.dart';
import 'repositories/interfaces/i_category_repository.dart';

import 'features/user/home/providers/home_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  final productRepo = ProductRepository();
  final categoryRepo = CategoryRepository();

  runApp(
    MultiProvider(
      providers: [
        /// GLOBAL REPO
        Provider<IProductRepository>.value(value: productRepo),
        Provider<ICategoryRepository>.value(value: categoryRepo),

        /// FEATURE PROVIDER
        ChangeNotifierProvider(create: (_) => HomeProvider(productRepo)),
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

      home: const SplashScreen(),
    );
  }
}
