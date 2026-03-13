import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/mock_products.dart';

import '../widgets/home_header.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  List<Product> allProducts = [];
  List<Product> products = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    await Future.delayed(const Duration(seconds: 2));

    allProducts =
        mockProducts; // Thay dổi thành dữ liệu thực gọi API VD: allProducts = await ApiService.fetchProducts();

    setState(() {
      products = allProducts;
      loading = false;
    });
  }

  void searchProducts(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        products = allProducts;
      });

      return;
    }

    final results =
        allProducts.where((product) {
          return product.name.toLowerCase().contains(keyword.toLowerCase());
        }).toList();

    setState(() {
      products = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef2fb),

      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),

            custom_widgets.SearchBar(
              controller: searchController,
              onChanged: searchProducts,
            ),

            ...const [
              SizedBox(height: 10),

              BannerSlider(),

              SizedBox(height: 10),

              CategoryList(),

              SizedBox(height: 10),
            ],

            Expanded(
              child: RefreshIndicator(
                onRefresh: loadProducts,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount =
                        constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
                            ? 3
                            : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      cacheExtent: 500,
                      itemCount: loading ? 6 : products.length,

                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),

                      itemBuilder: (context, index) {
                        if (loading) {
                          return const LoadingCard();
                        }

                        return ProductCard(product: products[index]);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
