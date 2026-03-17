import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/product.dart';
import '../repositories/i_product_repository.dart';
import '../screens/product_detail_screen.dart';
import '../config/app_config.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final IProductRepository repo; // Add repo

  const ProductCard({
    super.key,
    required this.product,
    required this.repo,
  });

  @override
  Widget build(BuildContext context) {

    /// Tránh null image
    final imageUrl = (product.mainImage != null &&
            product.mainImage!.isNotEmpty)
        ? "${AppConfig.apiUrl}/${product.mainImage}"
        : null;

    return GestureDetector(
      onTap: () {
        /// Navigate --> detail
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              productId: product.id,
              repo: repo,
            ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(14),

          /// Shadow
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,

                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),

                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      )
                    : Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image),
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),

            /// NAME
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 4),

            /// PRICE + RATING
            Row(
              children: [
                /// PRICE
                Text(
                  "${product.minPrice.toStringAsFixed(0)} đ",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                /// RATING
                const Icon(Icons.star, color: Colors.orange, size: 16),

                Text(
                  product.ratingAvg.toStringAsFixed(1),
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// BUTTON
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_cart,
                    size: 16,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        "Mua ngay",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}