import 'dart:async';
import 'package:flutter/material.dart';

import '../models/product.dart';
import '../repositories/product_repository.dart';

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
  final ProductRepository repo = ProductRepository();

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];
  List<Product> allProducts = [];

  bool loading = true;
  bool loadingMore = false;

  int page = 1;
  final int pageSize = 10;

  Timer? debounce;

  @override
  void initState() {
    super.initState();

    loadProducts();

    scrollController.addListener(scrollListener);
  }

  /// LOAD PRODUCTS
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      products.clear();
    }

    if (page == 1) {
      setState(() => loading = true);
    } else {
      setState(() => loadingMore = true);
    }

    try {
      final data = await repo.getHomeProducts(page: page, pageSize: pageSize);

      setState(() {
        if (page == 1) {
          products = data;
          allProducts = data;
        } else {
          products.addAll(data);
          allProducts.addAll(data);
        }

        loading = false;
        loadingMore = false;
      });
    } catch (e) {
      debugPrint("Load product error: $e");
    }
  }

  /// INFINITE SCROLL
  void scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !loadingMore) {
      page++;

      loadProducts();
    }
  }

  /// SEARCH WITH DEBOUNCE
  void searchProducts(String keyword) {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }

    debounce = Timer(const Duration(milliseconds: 400), () {
      if (keyword.isEmpty) {
        setState(() => products = allProducts);
        return;
      }

      final results =
          allProducts.where((p) {
            return p.name.toLowerCase().contains(keyword.toLowerCase());
          }).toList();

      setState(() => products = results);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
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

            const SizedBox(height: 10),

            const BannerSlider(),

            const SizedBox(height: 10),

            const CategoryList(),

            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await loadProducts(refresh: true);
                },

                child: LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount =
                        constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
                            ? 3
                            : 2;

                    return GridView.builder(
                      controller: scrollController,

                      padding: const EdgeInsets.all(12),

                      cacheExtent: 1000,

                      itemCount:
                          loading ? 6 : products.length + (loadingMore ? 2 : 0),

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

                        if (index >= products.length) {
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
