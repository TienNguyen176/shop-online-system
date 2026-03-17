import 'dart:async';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shopapp/services/product_service.dart';
import '../widgets/filter_sheet.dart';

import '../models/product.dart';
import '../models/product_filter.dart';
=======

import '../models/product.dart';
<<<<<<< HEAD
//import '../repositories/product_repository.dart';
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)
import '../repositories/i_product_repository.dart';
import '../repositories/category_repository.dart';

import '../widgets/home_header.dart';
import '../widgets/search_bar.dart' as custom_widgets;
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/product_card.dart';
import '../widgets/loading_card.dart';

class HomeScreen extends StatefulWidget {
<<<<<<< HEAD
  final IProductRepository repo;
=======
  final IProductRepository repo; // inject từ ngoài
>>>>>>> 4d9c391 (apply new gitignore rules)

  const HomeScreen({super.key, required this.repo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final IProductRepository repo;

  final categoryRepo = CategoryRepository();

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];
<<<<<<< HEAD

  /// allProducts = data gốc từ API, KHÔNG bao giờ bị filter/category ghi đè
  List<Product> allProducts = [];
  List<String> brands = [];
=======
  List<Product> allProducts = [];
>>>>>>> 4d9c391 (apply new gitignore rules)

  bool loading = true;
  bool loadingMore = false;
  bool hasMore = true;

<<<<<<< HEAD
  /// hasApiFilter = true khi đang dùng bộ lọc (brands/price/size/color)
  /// Chỉ true khi bấm "Áp dụng" từ FilterSheet
  bool hasApiFilter = false;

  /// selectedCategory = category đang chọn, "" = tất cả
  String selectedCategory = "";

  /// index của category đang chọn, dùng để sync với CategoryList
  int _selectedCategoryIndex = 0;

  final List<String> _categories = ["Tất cả", "Áo thun", "Áo khoác", "Giày", "Quần"];

=======
>>>>>>> 4d9c391 (apply new gitignore rules)
  int page = 1;
  final int pageSize = 8;

  int? selectedCategoryId;

  Timer? debounce;

<<<<<<< HEAD
  ProductFilter currentFilter = ProductFilter();

  /// Token để huỷ response cũ khi có request mới
  int _loadToken = 0;

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
=======
  @override
  void initState() {
    super.initState();

    repo = widget.repo;

    loadProducts();

    scrollController.addListener(scrollListener);
  }

  /// LOAD PRODUCTS
>>>>>>> 4d9c391 (apply new gitignore rules)
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      page = 1;
      hasMore = true;

      products.clear();
      allProducts.clear();
    }

    if (!hasMore) return;

<<<<<<< HEAD
    // Snapshot token + state tại thời điểm gọi
    final int token = ++_loadToken;
    final bool isApiFilter = hasApiFilter;
    final ProductFilter snapFilter = ProductFilter.from(currentFilter);
    final String snapSearch = searchController.text;

    if (page == 1) {
      setState(() => loading = true);
    } else {
      if (loadingMore) return;
=======
    if (page == 1) {
      setState(() => loading = true);
    } else {
      if (loadingMore) return; // Chống gọi nhiều lần
>>>>>>> 4d9c391 (apply new gitignore rules)
      setState(() => loadingMore = true);
    }

    try {
<<<<<<< HEAD
<<<<<<< HEAD
      final data = isApiFilter
          ? await repo.getProducts(
              page: page,
              pageSize: pageSize,
              brands: snapFilter.brands.isEmpty ? null : snapFilter.brands,
              colors: snapFilter.colors.isEmpty ? null : snapFilter.colors,
              sizes: snapFilter.sizes.isEmpty ? null : snapFilter.sizes,
              minPrice: snapFilter.minPrice,
              maxPrice: snapFilter.maxPrice,
              search: snapSearch,
            )
          : await repo.getHomeProducts(
              page: page,
              pageSize: pageSize,
            );

      // Nếu có request mới hơn đã được gọi thì bỏ qua response này
      if (token != _loadToken) {
        debugPrint(">>> Bỏ qua response cũ (token $token != $_loadToken)");
        return;
      }

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

      _applyLocalFilter();
    } catch (e) {
      debugPrint("Load error: $e");
      if (token != _loadToken) return;
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
    // Cập nhật state trước, tăng token để huỷ request cũ
    hasApiFilter = true;
    currentFilter = filter;
    page = 1;
    hasMore = true;
    allProducts = [];
    products = [];

    setState(() => loading = true);
    scrollController.jumpTo(0);

    await loadProducts(refresh: true);
  }

  /// ================= SCROLL =================
=======
      final data = await repo.getHomeProducts(page: page, pageSize: pageSize);
=======
      final data = await repo.getHomeProducts(
        page: page,
        pageSize: pageSize,
        categoryId: selectedCategoryId,
      );
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)

      setState(() {
        if (data.length < pageSize) {
          hasMore = false; // Hết data
        }

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
      //debugPrint("Load product error: $e");
    }
  }

  /// INFINITE SCROLL
>>>>>>> 4d9c391 (apply new gitignore rules)
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

<<<<<<< HEAD
  /// ================= SEARCH =================
  void searchProducts(String keyword) {
  if (debounce?.isActive ?? false) debounce!.cancel();

  debounce = Timer(const Duration(milliseconds: 400), () async {
    // Bỏ filter cũ, category cũ
    hasApiFilter = false;
    currentFilter = ProductFilter();
    selectedCategory = "";
    _selectedCategoryIndex = 0;

    // Không gán searchController.text nữa!
    // searchController.text = keyword;

    setState(() => loading = true);
    await loadProducts(refresh: true);
    _applyLocalFilter(); // filter local theo keyword hiện tại
  });
}
=======
  /// SEARCH WITH DEBOUNCE
  void searchProducts(String keyword) {
    if (debounce?.isActive ?? false) {
      debounce!.cancel();
    }

    debounce = Timer(const Duration(milliseconds: 400), () {
      if (keyword.isEmpty) {
        setState(() => products = List.from(allProducts));
        return;
      }

      final results =
          allProducts.where((p) {
            return p.name.toLowerCase().contains(keyword.toLowerCase());
          }).toList();

      setState(() => products = results);
    });
  }
>>>>>>> 4d9c391 (apply new gitignore rules)

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    debounce?.cancel();
<<<<<<< HEAD
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
=======
    scrollController.removeListener(scrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef2fb),

>>>>>>> 4d9c391 (apply new gitignore rules)
      body: SafeArea(
        child: Column(
          children: [
            const HomeHeader(),
<<<<<<< HEAD
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
              selectedIndex: _selectedCategoryIndex,
              onCategorySelected: (category) async {
                if (category == "Tất cả") {
                  hasApiFilter = false;
                  currentFilter = ProductFilter();
                  selectedCategory = "";
                  _selectedCategoryIndex = 0;
                  allProducts = [];
                  products = [];
                  searchController.clear();

                  setState(() => loading = true);
                  await loadProducts(refresh: true);
                } else {
                  // Chỉ set category rồi filter local, KHÔNG gọi API
                  setState(() {
                    selectedCategory = category;
                    _selectedCategoryIndex = _categories.indexOf(category);
                  });
                  _applyLocalFilter();
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  hasApiFilter = false;
                  currentFilter = ProductFilter();
                  selectedCategory = "";
                  _selectedCategoryIndex = 0;
                  searchController.clear();

                  setState(() => loading = true);
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
=======

            custom_widgets.SearchBar(
              controller: searchController,
              onChanged: searchProducts,
            ),

            const SizedBox(height: 10),

            const BannerSlider(),

            const SizedBox(height: 10),

            // Danh mục sản phẩm
            CategoryList(
              repo: categoryRepo,
              onSelected: (categoryId) {
                setState(() {
                  selectedCategoryId = categoryId;
                });

                loadProducts(refresh: true);
              },
            ),

            const SizedBox(height: 10),

            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await loadProducts(refresh: true);
                },

                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (!loading && products.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text("Không có sản phẩm"),
                          ],
                        ),
                      );
                    }

                    int crossAxisCount =
                        constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
>>>>>>> 4d9c391 (apply new gitignore rules)
                            ? 3
                            : 2;

                    return GridView.builder(
                      controller: scrollController,
<<<<<<< HEAD
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
=======

                      physics: const BouncingScrollPhysics(),

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
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(),
                            ),
>>>>>>> 4d9c391 (apply new gitignore rules)
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 4d9c391 (apply new gitignore rules)
