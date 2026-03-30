import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../repositories/interfaces/i_category_repository.dart';
import '../providers/home_provider.dart';

import '../widgets/home_header.dart';
import '../../../../widgets/search_bar.dart' as custom_widgets;
import '../widgets/banner_slider.dart';
import '../widgets/category_list.dart';
import '../../product/widgets/product_card.dart';
import '../../../../widgets/loading_card.dart';

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
      context.read<HomeProvider>().loadProducts();
    }
  }

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final provider = context.read<HomeProvider>();

      final isNearBottom =
          scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200;

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
          body: SafeArea(
            child: Column(
              children: [
                const HomeHeader(),

                /// SEARCH
                custom_widgets.SearchBar(
                  controller: searchController,
                  onChanged: provider.search,
                ),

                const SizedBox(height: 10),

                const BannerSlider(),

                const SizedBox(height: 10),

                /// CATEGORY
                CategoryList(
                  repo: context.read<ICategoryRepository>(),
                  onSelected: provider.selectCategory,
                ),

                const SizedBox(height: 10),

                /// LIST
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.loadProducts(refresh: true),

                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (!provider.loading && provider.products.isEmpty) {
                          return const Center(child: Text("Không có sản phẩm"));
                        }

                        int crossAxisCount =
                            constraints.maxWidth > 900
                                ? 4
                                : constraints.maxWidth > 600
                                ? 3
                                : 2;

                        return GridView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.all(12),

                          itemCount:
                              provider.loading
                                  ? 6
                                  : provider.products.length +
                                      (provider.loadingMore ? 2 : 0),

                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.68,
                              ),

                          itemBuilder: (context, index) {
                            if (provider.loading) {
                              return const LoadingCard();
                            }

                            if (index >= provider.products.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final product = provider.products[index];

                            return ProductCard(
                              key: ValueKey(product.id),
                              product: product,
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
      },
    );
  }
}
