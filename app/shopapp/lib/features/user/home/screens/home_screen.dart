import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../../auth/providers/auth_provider.dart';

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

  /// ===== BASE URL =====
  String getFullAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "http://192.168.1.148:5000$path";
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeProvider>().loadProducts();
      });
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

  /// ================= POPUP PROFILE =================
  void _showProfileMenu(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// AVATAR
                CircleAvatar(
                  radius: 35,
                  backgroundImage:
                      user?['avatar'] != null
                          ? NetworkImage(getFullAvatarUrl(user!['avatar']))
                          : null,
                  child:
                      user?['avatar'] == null
                          ? const Icon(Icons.person, size: 30)
                          : null,
                ),

                const SizedBox(height: 10),

                /// NAME
                Text(
                  user?['fullName'] ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                /// EMAIL
                Text(
                  user?['email'] ?? "",
                  style: const TextStyle(color: Colors.grey),
                ),

                const Divider(height: 20),

                /// PROFILE BUTTON
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text("Thông tin cá nhân"),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/profile");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, provider, _) {
        final user = context.watch<AuthProvider>().user;

        return Scaffold(
          backgroundColor: const Color(0xffeef2fb),

          body: SafeArea(
            child: Column(
              children: [
                /// ================= HEADER + AVATAR =================
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShaderMask(
                        shaderCallback:
                            (bounds) => const LinearGradient(
                              colors: [Colors.blue, Colors.red],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                        child: const Text(
                          "NEXT4SHOP",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic, // chữ nghiêng
                            color: Colors.white, // bắt buộc để hiện gradient
                            shadows: [
                              Shadow(
                                blurRadius: 8,
                                color: Colors.redAccent,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () => _showProfileMenu(context),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundImage:
                              user?['avatar'] != null
                                  ? NetworkImage(
                                    getFullAvatarUrl(user!['avatar']),
                                  )
                                  : null,
                          child:
                              user?['avatar'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                        ),
                      ),
                    ],
                  ),
                ),

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
                  onSelected: (categoryId) {
                    context.read<HomeProvider>().selectCategory(categoryId);
                  },
                ),

                const SizedBox(height: 10),

                /// PRODUCT LIST
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
