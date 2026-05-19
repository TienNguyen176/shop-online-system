import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../helpers/cart_helper.dart';
import '../../../../models/product_detail.dart';
import '../../../../models/product_variant.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/cart_item_badge.dart';
import '../../notification/providers/notification_provider.dart';
import '../providers/product_detail_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _loading = false;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductDetailProvider>().load(widget.productId);
      final notificationProvider = context.read<NotificationProvider>();
      if (notificationProvider.notifications.isEmpty) {
        notificationProvider.loadNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductDetailProvider>(
      builder: (context, provider, child) {
        if (provider.loading) {
          return const Scaffold(
            backgroundColor: Color(0xffeef2fb),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xff2563eb)),
            ),
          );
        }

        final product = provider.product;
        if (product == null) {
          return const Scaffold(
            backgroundColor: Color(0xffeef2fb),
            body: Center(child: Text("Không tìm thấy sản phẩm")),
          );
        }

        final variant = provider.selectedVariant;
        final canBuy = variant != null && variant.stockQuantity > 0;

        return Scaffold(
          backgroundColor: const Color(0xffeef2fb),
          bottomNavigationBar: _BottomActions(
            loading: _loading,
            canBuy: canBuy,
            onAddToCart: () => _handleAddToCart(provider),
          ),
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(onBack: () => Navigator.pop(context)),
                ),
                SliverToBoxAdapter(
                  child: _ImageGallery(
                    images: _visibleImages(product, provider),
                    imageIndex: _imageIndex,
                    onChanged: (index) => setState(() => _imageIndex = index),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _InfoPanel(
                    product: product,
                    variant: variant,
                    provider: provider,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<String> _visibleImages(
    ProductDetail product,
    ProductDetailProvider provider,
  ) {
    String? variantImage;
    for (final value in provider.selectedAttributes.values) {
      final image = product.imagesByColor[value];
      if (image != null) {
        variantImage = image;
        break;
      }
    }

    final images = [
      if (variantImage != null) variantImage,
      ...product.images.where((image) => image != variantImage),
    ];

    return images;
  }

  Future<void> _handleAddToCart(ProductDetailProvider provider) async {
    if (_loading) return;

    final variant = provider.selectedVariant;
    if (variant == null || variant.stockQuantity <= 0) {
      _showSnack("Sản phẩm đã hết hàng");
      return;
    }

    setState(() => _loading = true);

    try {
      await CartHelper.addToCart(
        context: context,
        productId: provider.product!.id,
        selectedVariant: variant,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onPressed: onBack,
          ),
          const Spacer(),
          const _NotificationButton(),
          const SizedBox(width: 6),
          const CartIconWithBadge(),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final count = provider.unreadCount;
        return Stack(
          children: [
            IconButton(
              tooltip: "Thông báo",
              onPressed:
                  () => Navigator.pushNamed(context, AppRoutes.notifications),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xff1f2937),
              ),
            ),
            if (count > 0)
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xffef4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    count > 99 ? "99+" : "$count",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1d4ed8).withOpacity(0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: const Color(0xff1f2937)),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  final List<String> images;
  final int imageIndex;
  final ValueChanged<int> onChanged;

  const _ImageGallery({
    required this.images,
    required this.imageIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1d4ed8).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: 1,
        child:
            images.isEmpty
                ? const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 56,
                    color: Color(0xff94a3b8),
                  ),
                )
                : Stack(
                  children: [
                    PageView.builder(
                      itemCount: images.length,
                      onPageChanged: onChanged,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _imageUrl(images[index]),
                          fit: BoxFit.contain,
                          errorBuilder:
                              (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 52,
                                  color: Color(0xff94a3b8),
                                ),
                              ),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xff2563eb),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          final selected = imageIndex == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: selected ? 18 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? const Color(0xff2563eb)
                                      : const Color(0xffcbd5e1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  static String _imageUrl(String path) {
    if (path.startsWith("http://") || path.startsWith("https://")) {
      return path;
    }

    final cleanApi = AppConfig.apiUrl.replaceAll(RegExp(r"/+$"), "");
    final cleanPath = path.replaceAll(RegExp(r"^/+"), "");
    return "$cleanApi/$cleanPath";
  }
}

class _InfoPanel extends StatelessWidget {
  final ProductDetail product;
  final ProductVariant? variant;
  final ProductDetailProvider provider;

  const _InfoPanel({
    required this.product,
    required this.variant,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final stock = variant?.stockQuantity ?? 0;
    final inStock = stock > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1d4ed8).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "${_formatPrice(variant?.price ?? product.minPrice)}đ",
                  style: const TextStyle(
                    color: Color(0xffdc2626),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _StockPill(inStock: inStock, stock: stock),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: const TextStyle(
              color: Color(0xff111827),
              fontSize: 19,
              height: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xffff8a00), size: 20),
              const SizedBox(width: 4),
              Text(
                product.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Color(0xff1f2937),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xffef4444),
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                "Đã bán ${product.soldCount}",
                style: const TextStyle(
                  color: Color(0xff64748b),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...product.attributes.map((attr) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attr.name,
                    style: const TextStyle(
                      color: Color(0xff1f2937),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 9,
                    runSpacing: 9,
                    children:
                        attr.values.map((value) {
                          final selected =
                              provider.selectedAttributes[attr.name] == value;
                          final hasStock = _hasStockForValue(attr.name, value);

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => provider.select(attr.name, value),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 13,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    selected
                                        ? const Color(0xffdbeafe)
                                        : const Color(0xfff8fafc),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      selected
                                          ? const Color(0xff2563eb)
                                          : const Color(0xffe5e7eb),
                                ),
                              ),
                              child: Text(
                                value,
                                style: TextStyle(
                                  color:
                                      hasStock
                                          ? const Color(0xff1f2937)
                                          : const Color(0xff94a3b8),
                                  fontWeight:
                                      selected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Color(0xffe5e7eb)),
          const SizedBox(height: 12),
          const Text(
            "Mô tả sản phẩm",
            style: TextStyle(
              color: Color(0xff1f2937),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            product.description.isEmpty ? "Chưa có mô tả" : product.description,
            style: const TextStyle(
              color: Color(0xff475569),
              fontSize: 14,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasStockForValue(String key, String value) {
    return product.variants.any(
      (variant) => variant.attributes[key] == value && variant.stockQuantity > 0,
    );
  }

  static String _formatPrice(double value) {
    final text = value.round().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      buffer.write(text[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        buffer.write(".");
      }
    }
    return buffer.toString();
  }
}

class _StockPill extends StatelessWidget {
  final bool inStock;
  final int stock;

  const _StockPill({required this.inStock, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: inStock ? const Color(0xffdcfce7) : const Color(0xffffe4e6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        inStock ? "Còn hàng: $stock" : "Hết hàng",
        style: TextStyle(
          color: inStock ? const Color(0xff15803d) : const Color(0xffbe123c),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final bool loading;
  final bool canBuy;
  final VoidCallback onAddToCart;

  const _BottomActions({
    required this.loading,
    required this.canBuy,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff2563eb),
                  side: const BorderSide(color: Color(0xff2563eb)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: loading || !canBuy ? null : onAddToCart,
                icon:
                    loading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.add_shopping_cart_rounded),
                label: const Text(
                  "Thêm vào giỏ",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563eb),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xffcbd5e1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: loading || !canBuy ? null : onAddToCart,
                child: const Text(
                  "Mua ngay",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
