import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../helpers/cart_helper.dart';
import '../../../../models/product_variant.dart';

import '../../../../models/product.dart';
import '../../../../services/product/product_service.dart';
import '../screens/product_detail_screen.dart';
import '../../../../core/config/app_config.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _loading = false;

  ProductVariant? _cachedVariant;

  Product get product => widget.product;

  // ================= ADD TO CART =================
  Future<void> _handleAddToCart() async {
    if (_loading) return;

    setState(() => _loading = true);

    try {
      await CartHelper.addToCart(
        context: context,
        productId: product.id,
        fetchVariant: _fetchFirstVariant,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (product.mainImage != null && product.mainImage!.isNotEmpty)
            ? "${AppConfig.apiUrl}/${product.mainImage}"
            : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(10),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(imageUrl),
          const SizedBox(height: 8),
          _buildName(),
          const SizedBox(height: 4),
          _buildPriceRow(),
          const SizedBox(height: 8),
          _buildActions(),
        ],
      ),
    );
  }

  // ================= WIDGET PARTS =================

  Widget _buildImage(String? imageUrl) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              imageUrl != null
                  ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (_, __) => _imagePlaceholder(),
                    errorWidget: (_, __, ___) => _imageError(),
                  )
                  : _imageError(),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _imageError() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.image)),
    );
  }

  Widget _buildName() {
    return Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis);
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Text(
          "${product.minPrice.toStringAsFixed(0)} đ",
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const Icon(Icons.star, color: Colors.orange, size: 16),
        Text(product.ratingAvg.toStringAsFixed(1)),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        _buildAddToCartButton(),
        const SizedBox(width: 10),
        Expanded(child: _buildBuyNowButton()),
      ],
    );
  }

  // ================= BUTTON =================

  Widget _buildAddToCartButton() {
    return AbsorbPointer(
      absorbing: _loading,
      child: InkWell(
        onTap: _handleAddToCart,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _loading ? Colors.grey : Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                _loading
                    ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(
                      Icons.shopping_cart,
                      size: 16,
                      color: Colors.white,
                    ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text("Mua ngay", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  Future<ProductVariant?> _fetchFirstVariant() async {
    if (_cachedVariant != null) return _cachedVariant;

    try {
      final productService = ProductService();
      final detail = await productService.getProductDetail(product.id);

      if (detail.variants.isNotEmpty) {
        _cachedVariant = detail.variants.first;
      }

      return _cachedVariant;
    } catch (_) {
      return null;
    }
  }
}
