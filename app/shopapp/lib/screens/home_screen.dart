import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shopapp/services/product_service.dart';
import '../widgets/filter_sheet.dart';

import '../models/product.dart';
import '../models/product_filter.dart';
import '../repositories/i_product_repository.dart';

import '../widgets/home_header.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_card.dart';

class HomeScreen extends StatefulWidget {
  final IProductRepository repo;

  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final IProductRepository repo;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];

  /// allProducts = data gốc từ API, KHÔNG bao giờ bị filter/category ghi đè
  List<Product> allProducts = [];
  List<String> brands = [];

  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;

  /// hasApiFilter = true khi đang dùng bộ lọc (brands/price/size/color)
  /// Chỉ true khi bấm "Áp dụng" từ FilterSheet
  bool hasApiFilter = false;

  /// selectedCategory = category đang chọn, "" = tất cả
  String selectedCategory = "";

  int page = 1;
  final int pageSize = 10;

  Timer? debounce;

  ProductFilter currentFilter = ProductFilter();

  @override
  void initState() {
    super.initState();
    repo = widget.repo;
    loadProducts();
    loadBrands();
    scrollController.addListener(scrollListener);
  }

  /// ================= LOAD BRANDS =================
  Future<void> loadBrands() async {
    try {
      final data = await repo.getBrands();
      setState(() => brands = data);
    } catch (e) {
      debugPrint("Load brands error: $e");
    }
  }

  /// ================= LOAD PRODUCTS (API) =================
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      hasMore = true;
    }

    if (!hasMore) return;

    if (page == 1) {
      setState(() => loading = true);
    } else {
      if (loadingMore) return;
      setState(() => loadingMore = true);
    }

    try {
      final data = hasApiFilter
          ? await repo.getProducts(
              page: page,
              pageSize: pageSize,
              brands: currentFilter.brands.isEmpty ? null : currentFilter.brands,
              colors: currentFilter.colors.isEmpty ? null : currentFilter.colors,
              sizes: currentFilter.sizes.isEmpty ? null : currentFilter.sizes,
              minPrice: currentFilter.minPrice,
              maxPrice: currentFilter.maxPrice,
              search: searchController.text,
            )
          : await repo.getHomeProducts(
              page: page,
              pageSize: pageSize,
            );

      if (page == 1) {
        allProducts = data;
      } else {
        allProducts = [...allProducts, ...data];
      }

      setState(() {
        if (data.length < pageSize) hasMore = false;
        loading = false;
        loadingMore = false;
      });

      // Sau khi load xong luôn apply lại category + search local
      _applyLocalFilter();
    } catch (e) {
      debugPrint("Load error: $e");
      setState(() {
        loading = false;
        loadingMore = false;
      });
    }
  }

  /// ================= LOCAL FILTER =================
  /// Chỉ filter category + search trên allProducts hiện có
  void _applyLocalFilter() {
    final keyword = searchController.text.trim().toLowerCase();

    setState(() {
      products = allProducts.where((p) {
        final name = (p.name ?? "").toLowerCase();
        final category = (p.category ?? "").toLowerCase();

        final matchSearch = keyword.isEmpty || name.contains(keyword);
        final matchCategory = selectedCategory.isEmpty ||
            category == selectedCategory.toLowerCase();

        return matchSearch && matchCategory;
      }).toList();
    });
  }

  /// ================= FILTER (FilterSheet) =================
  Future<void> applyFilter(ProductFilter filter) async {
    setState(() {
      loading = true;
      page = 1;
      hasMore = true;
      hasApiFilter = true;
      products.clear();
      allProducts.clear();
      currentFilter = filter;
    });

    scrollController.jumpTo(0);

    try {
      final data = await repo.getProducts(
        page: 1,
        pageSize: pageSize,
        brands: filter.brands.isEmpty ? null : filter.brands,
        colors: filter.colors.isEmpty ? null : filter.colors,
        sizes: filter.sizes.isEmpty ? null : filter.sizes,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        search: searchController.text,
      );

      allProducts = data;

      setState(() {
        if (data.length < pageSize) hasMore = false;
        loading = false;
      });

      _applyLocalFilter();
    } catch (e) {
      debugPrint("Filter error: $e");
      setState(() => loading = false);
    }
  }

  /// ================= SCROLL =================
  void scrollListener() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !loadingMore &&
        !loading &&
        hasMore) {
      page++;
      loadProducts();
    }
  }

  /// ================= SEARCH =================
  void searchProducts(String keyword) {
    if (debounce?.isActive ?? false) debounce!.cancel();

    debounce = Timer(const Duration(milliseconds: 400), () {
      // Luôn filter local — search chỉ lọc trên allProducts đã có
      _applyLocalFilter();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    debounce?.cancel();
    super.dispose();
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final bool showEmpty = !loading &&
        products.isEmpty &&
        (selectedCategory.isNotEmpty ||
            searchController.text.isNotEmpty ||
            hasApiFilter);

    return Scaffold(
      backgroundColor: const Color(0xffeef2fb),
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
            custom_widgets.SearchBar(
              controller: searchController,
              onChanged: searchProducts,
              onFilter: () async {
                final result = await showDialog<ProductFilter>(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: SizedBox(
                        height: 400,
                        child: FilterSheet(
                          brands: brands,
                          selectedSizes: currentFilter.sizes ?? [],
                          selectedColors: currentFilter.colors ?? [],
                        ),
                      ),
                    );
                  },
                );

                if (result != null) {
                  if (result.brands.isNotEmpty) {
                    List<String> allSizes = [];
                    List<String> allColors = [];

                    for (var b in result.brands) {
                      final attrs =
                          await ProductService().getBrandAttributes(b) ?? {};
                      allSizes.addAll(attrs['Size'] ?? []);
                      allColors.addAll(attrs['Color'] ?? []);
                    }

                    result.sizes = allSizes.toSet().toList();
                    result.colors = allColors.toSet().toList();
                  }

                  setState(() => currentFilter = result);
                  await applyFilter(result);
                }
              },
            ),
            const SizedBox(height: 10),
            const BannerSlider(),
            const SizedBox(height: 10),
            CategoryList(
              onCategorySelected: (category) async {
                if (category == "Tất cả") {
                  // Reset hoàn toàn về home
                  setState(() {
                    selectedCategory = "";
                    hasApiFilter = false;
                    currentFilter = ProductFilter();
                  });
                  searchController.clear();
                  await loadProducts(refresh: true);
                } else {
                  // Chỉ set category rồi filter local, KHÔNG gọi API
                  setState(() => selectedCategory = category);
                  _applyLocalFilter();
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    currentFilter = ProductFilter();
                    hasApiFilter = false;
                    selectedCategory = "";
                  });
                  searchController.clear();
                  await loadProducts(refresh: true);
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (showEmpty) {
                      return const Center(child: Text("Không có sản phẩm"));
                    }

                    int crossAxisCount = constraints.maxWidth > 900
                        ? 4
                        : constraints.maxWidth > 600
                            ? 3
                            : 2;

                    return GridView.builder(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      cacheExtent: 1000,
                      itemCount: loading
                          ? 6
                          : products.length + (loadingMore ? 2 : 0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        if (loading) return const LoadingCard();

                        if (index >= products.length) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ProductCard(
                          product: products[index],
                          repo: repo,
                        );
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