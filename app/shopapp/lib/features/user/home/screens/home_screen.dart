import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../../../repositories/interfaces/i_product_repository.dart';
import '../../../../widgets/app_bottom_nav.dart';
import '../../../../widgets/loading_card.dart';
import '../../../../widgets/product_filter_dialog.dart';
import '../../../../widgets/search_bar.dart' as custom_widgets;
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../../product/models/product_browse_args.dart';
import '../../product/widgets/product_card.dart';
import '../../../admin/category/providers/category_provider.dart';
import '../providers/home_provider.dart';
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../widgets/home_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = context.read<HomeProvider>();
        provider.loadBannerProducts();
        provider.loadProducts();

        final userId = _currentUserId(context);
        if (userId != null) {
          context.read<CartProvider>().loadCart(userId);
        }
      });
    }
  }

  int? _currentUserId(BuildContext context) {
    final id = context.read<AuthProvider>().user?["id"];
    if (id is int) return id;
    return int.tryParse(id?.toString() ?? "");
  }

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final provider = context.read<HomeProvider>();

      final isNearBottom =
          scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 240;

      if (isNearBottom &&
          !provider.loadingMore &&
          !provider.loading &&
          provider.hasMore) {
        provider.loadMore();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xffeef2fb),
          bottomNavigationBar: const AppBottomNav(
            activeItem: AppBottomNavItem.home,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: const Color(0xff2563eb),
              onRefresh: () => provider.loadProducts(refresh: true),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      constraints.maxWidth > 900
                          ? 4
                          : constraints.maxWidth > 600
                          ? 3
                          : 2;

                  final itemCount =
                      provider.loading
                          ? 6
                          : provider.products.length +
                              (provider.loadingMore ? 2 : 0);

                  return CustomScrollView(
                    controller: scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: HomeHeader()),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            custom_widgets.SearchBar(
                              controller: searchController,
                              onChanged: provider.search,
                              onSubmitted: _openProductsBySearch,
                              onFilterTap: _showFilterDialog,
                            ),
                            const SizedBox(height: 22),
                            const _SectionHeader(title: "Categories"),
                            const SizedBox(height: 8),
                            CategoryList(
                              onSelected: (categoryId) {
                                context.read<HomeProvider>().selectCategory(
                                  categoryId,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            BannerSlider(products: provider.bannerProducts),
                            const SizedBox(height: 18),
                            _SectionHeader(
                              title: "Trending Now",
                              onSeeAll: () => _openProducts(
                                const ProductBrowseArgs(title: "Products"),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      if (!provider.loading && provider.products.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              "Khong co san pham",
                              style: TextStyle(color: Color(0xff6b7280)),
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 0.66,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              if (provider.loading) {
                                return const LoadingCard();
                              }

                              if (index >= provider.products.length) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xff2563eb),
                                  ),
                                );
                              }

                              final product = provider.products[index];

                              return ProductCard(
                                key: ValueKey(product.id),
                                product: product,
                              );
                            }, childCount: itemCount),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _openProducts(ProductBrowseArgs args) {
    Navigator.pushNamed(context, AppRoutes.userProducts, arguments: args);
  }

  void _openProductsBySearch(String keyword) {
    final trimmed = keyword.trim();
    _openProducts(
      ProductBrowseArgs(
        searchKeyword: trimmed.isEmpty ? null : trimmed,
        title: trimmed.isEmpty ? "Products" : "Search: $trimmed",
      ),
    );
  }

  Future<void> _showFilterDialog() async {
    final result = await showDialog<ProductBrowseArgs>(
      context: context,
      builder:
          (_) => ProductFilterDialog(
            initialArgs: const ProductBrowseArgs(),
            categories: context.read<CategoryProvider>().categories,
            brandsFuture: context.read<IProductRepository>().getBrands(),
            storageKey: "home_filter_dialog_list",
          ),
    );

    if (result != null && mounted) {
      _openProducts(result);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff1f2937),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          if (onSeeAll != null) ...[
            const Spacer(),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff2563eb),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              onPressed: onSeeAll,
              child: const Text(
                "See All",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
