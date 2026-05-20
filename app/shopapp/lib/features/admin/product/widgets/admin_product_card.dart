import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/admin_product_model.dart';
import '../../../../core/config/app_config.dart';

class AdminProductCard extends StatelessWidget {
  final AdminProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AdminProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final imageUrl =
        (product.image != null && product.image!.isNotEmpty)
            ? "${AppConfig.apiUrl}/${product.image}"
            : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
            /// IMAGE
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child:
                    imageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: imageUrl,

                          fit: BoxFit.cover,

                          /// LOADING
                          placeholder:
                              (context, url) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),

                          /// ERROR
                          errorWidget:
                              (context, url, error) =>
                                  const Icon(Icons.broken_image),
                        )
                        : const Icon(Icons.image),
              ),
            ),

            const SizedBox(width: 12),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Thể loại: ${product.categoryName ?? 'Chưa có thể loại'}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Thương hiệu: ${product.brand ?? 'Chưa có thương hiệu'}",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text("Đánh giá: ${product.rating}"),
                    ],
                  ),
                ],
              ),
            ),

            /// ACTION
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case "edit":
                    onEdit?.call();
                    break;
                  case "delete":
                    onDelete?.call();
                    break;
                }
              },
              itemBuilder:
                  (context) => const [
                    PopupMenuItem(value: "edit", child: Text("Sửa")),
                    PopupMenuItem(value: "delete", child: Text("Xóa")),
                  ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}
