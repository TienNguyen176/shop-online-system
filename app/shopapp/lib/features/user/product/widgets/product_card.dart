import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/config/app_config.dart';
import '../../../../helpers/cart_helper.dart';
import '../../../../models/product.dart';
import '../../../../models/product_variant.dart';
import '../../../../services/product/product_service.dart';
import '../screens/product_detail_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (product.mainImage != null && product.mainImage!.isNotEmpty)
            ? "${AppConfig.apiUrl}/${product.mainImage}"
            : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1d4ed8).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(imageUrl),
          const SizedBox(height: 8),
          _buildName(),
          const SizedBox(height: 5),
          _buildPriceRow(),
          const SizedBox(height: 10),
          _buildActions(),
        ],
      ),
    );
  }

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
          borderRadius: BorderRadius.circular(16),
          child:
              imageUrl != null
                  ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
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
      color: const Color(0xffe0ecff),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _imageError() {
    return Container(
      color: const Color(0xffe0ecff),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Color(0xff9ca3af)),
      ),
    );
  }

  Widget _buildName() {
    return Text(
      product.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Color(0xff1f2937),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.15,
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      children: [
        Text(
          "${product.minPrice.toStringAsFixed(0)} d",
          style: const TextStyle(
            color: Color(0xff2563eb),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        const Icon(Icons.star_rounded, color: Color(0xffffb020), size: 15),
        const SizedBox(width: 2),
        Text(
          product.ratingAvg.toStringAsFixed(1),
          style: const TextStyle(
            color: Color(0xff6b7280),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
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

  Widget _buildAddToCartButton() {
    return AbsorbPointer(
      absorbing: _loading,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _handleAddToCart,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _loading ? Colors.grey : const Color(0xff2563eb),
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
                      Icons.shopping_bag_outlined,
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
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xff1e3a8a),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Text(
          "Buy now",
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
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
