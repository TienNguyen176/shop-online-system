import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/product.dart';
import '../../../../repositories/interfaces/i_product_repository.dart';
import '../../../../widgets/app_bottom_nav.dart';
import '../../../../widgets/loading_card.dart';
import '../../../../widgets/product_filter_dialog.dart';
import '../../../../widgets/search_bar.dart' as custom_widgets;
import '../../../admin/category/providers/category_provider.dart';
import '../models/product_browse_args.dart';
import '../widgets/product_card.dart';

/// Màn duyệt sản phẩm theo tìm kiếm, danh mục, thương hiệu và bộ lọc.
class ProductBrowseScreen extends StatefulWidget {
  final ProductBrowseArgs args;

  const ProductBrowseScreen({
    super.key,
    this.args = const ProductBrowseArgs(),
  });

  /// Tao state quan ly vong doi cua widget.
  @override
  State<ProductBrowseScreen> createState() => _ProductBrowseScreenState();
}

class _ProductBrowseScreenState extends State<ProductBrowseScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  final List<Product> _products = [];
  final Set<int> _loadedIds = {};

  late ProductBrowseArgs _args;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;
  bool _fetching = false;

  int _page = 1;
  static const int _pageSize = 12;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _args = widget.args;
    _searchController.text = _args.searchKeyword ?? "";
    _loadProducts(refresh: true);

    _scrollController.addListener(() {
      final nearBottom =
          _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 240;

      if (nearBottom && !_loading && !_loadingMore && _hasMore) {
        _loadMore();
      }
    });
  }

  /// Giai phong controller, listener va tai nguyen khi widget bi huy.
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Xu ly thay doi vong doi ung dung.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProducts(refresh: true);
    }
  }

  /// Tải danh sách sản phẩm theo filter hiện tại, có thể refresh về trang đầu.
  Future<void> _loadProducts({bool refresh = false}) async {
    if (_fetching) return;

    _fetching = true;

    if (refresh) {
      _page = 1;
      _hasMore = true;
      _products.clear();
      _loadedIds.clear();
    }

    if (!_hasMore) {
      _fetching = false;
      return;
    }

    setState(() {
      if (_products.isEmpty) {
        _loading = true;
      }
    });

    try {
      final repo = context.read<IProductRepository>();
      final data = await repo.getHomeProducts(
        page: _page,
        pageSize: _pageSize,
        categoryId: _args.categoryId,
        categoryIds: _args.categoryIds,
        search: _args.searchKeyword,
        brand: _args.brand,
        brands: _args.brands,
        minRating: _args.minRating,
        minPrice: _args.minPrice,
        maxPrice: _args.maxPrice,
        forceRefresh: refresh,
      );

      final filtered = data.where((p) => _loadedIds.add(p.id)).toList();

      if (data.length < _pageSize || filtered.isEmpty) {
        _hasMore = false;
      }

      _products.addAll(filtered);
      if (filtered.isNotEmpty) {
        _page++;
      }
    } catch (_) {
      _hasMore = false;
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
      _loadingMore = false;
      _fetching = false;
    });
  }

  /// Tải thêm sản phẩm khi người dùng cuộn gần cuối danh sách.
  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    await _loadProducts();
  }

  /// Áp dụng tham số duyệt sản phẩm từ màn khác truyền sang.
  void _applyArgs(ProductBrowseArgs args) {
    setState(() {
      _args = args;
      _searchController.text = args.searchKeyword ?? "";
      _fetching = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    _loadProducts(refresh: true);
  }

  /// Cập nhật keyword và reload danh sách sản phẩm.
  void _searchProducts(String keyword) {
    final trimmed = keyword.trim();
    _applyArgs(
      _args.copyWith(
        searchKeyword: trimmed.isEmpty ? null : trimmed,
        title: trimmed.isEmpty ? "Sản phẩm" : "Tìm kiếm: $trimmed",
        clearSearchKeyword: trimmed.isEmpty,
      ),
    );
  }

  /// Mở dialog lọc sản phẩm và áp dụng bộ lọc được chọn.
  Future<void> _showFilterDialog() async {
    final result = await showDialog<ProductBrowseArgs>(
      context: context,
      builder:
          (_) => ProductFilterDialog(
            initialArgs: _args,
            categories: context.read<CategoryProvider>().categories,
            brandsFuture: context.read<IProductRepository>().getBrands(),
            storageKey: "product_filter_dialog_list",
          ),
    );

    if (result != null && mounted) {
      _applyArgs(result);
    }
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef2fb),
      appBar: AppBar(
        backgroundColor: const Color(0xff2563eb),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(_args.title ?? "Sản phẩm"),
        centerTitle: true,
      ),
      bottomNavigationBar: const AppBottomNav(
        activeItem: AppBottomNavItem.product,
      ),
      body: RefreshIndicator(
        color: const Color(0xff2563eb),
        onRefresh: () => _loadProducts(refresh: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount =
                constraints.maxWidth > 900
                    ? 4
                    : constraints.maxWidth > 600
                    ? 3
                    : 2;
            final itemCount =
                _loading ? 6 : _products.length + (_loadingMore ? 2 : 0);

            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: custom_widgets.SearchBar(
                      controller: _searchController,
                      onChanged: (_) {},
                      onSubmitted: _searchProducts,
                      onFilterTap: _showFilterDialog,
                    ),
                  ),
                ),
                if (!_loading && _products.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        "Không có sản phẩm",
                        style: TextStyle(color: Color(0xff64748b)),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.66,
                      ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (_loading) {
                          return const LoadingCard();
                        }

                        if (index >= _products.length) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff2563eb),
                            ),
                          );
                        }

                        return ProductCard(
                          key: ValueKey(_products[index].id),
                          product: _products[index],
                        );
                      }, childCount: itemCount),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
