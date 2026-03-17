import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'repositories/product_repository.dart';
import 'repositories/i_product_repository.dart';

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
    final IProductRepository repo = ProductRepository();

    return MaterialApp(
      title: 'Shop App',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xffeef2fb),
      ),

      /// Route
      home: HomeScreen(repo: repo),
    );
  }
}
