import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shopapp/repositories/cart_repository.dart';
import 'package:shopapp/screens/shoppingcar.dart';
=======
>>>>>>> 4d9c391 (apply new gitignore rules)
import '../repositories/i_product_repository.dart';
import '../models/product_detail.dart';
import '../models/product_variant.dart';
import '../config/app_config.dart';

<<<<<<< HEAD
final CartRepository cartRepo = CartRepository();

=======
>>>>>>> 4d9c391 (apply new gitignore rules)
class ProductDetailScreen extends StatefulWidget {
  final int productId;
  final IProductRepository repo;

  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.repo,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetail? product;
  bool loading = true;

  Map<String, String> selectedAttributes = {};

  @override
  void initState() {
    super.initState();
    loadDetail();
  }

  Future<void> loadDetail() async {
    final data = await widget.repo.getProductDetail(widget.productId);

    Map<String, String> defaultSelected = {};
    for (var attr in data.attributes) {
      if (attr.values.isNotEmpty) {
        defaultSelected[attr.name] = attr.values.first;
      }
    }

    setState(() {
      product = data;
      selectedAttributes = defaultSelected;
      loading = false;
    });
  }

  ProductVariant? get selectedVariant {
    if (product == null) return null;

    try {
      return product!.variants.firstWhere((v) {
        for (var key in selectedAttributes.keys) {
          if (v.attributes[key] != selectedAttributes[key]) {
            return false;
          }
        }
        return true;
      });
    } catch (e) {
      return null;
    }
  }

<<<<<<< HEAD
  // ✅ ADD TO CART API (MỚI)
 // ✅ addToCart — fix null variantId
Future<void> addToCart() async {
  final variant = selectedVariant;

  if (variant == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vui lòng chọn phân loại sản phẩm")),
    );
    return;
  }

  // ✅ Kiểm tra variantId null trước khi gọi API
  final int? vid = variant.variantId;
  if (vid == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Biến thể không hợp lệ")),
    );
    return;
  }

  await cartRepo.addToCart(
    productId: widget.productId,
    variantId: vid,   // ✅ đã check null, không crash
    quantity: 1,
  );
}

=======
>>>>>>> 4d9c391 (apply new gitignore rules)
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final variant = selectedVariant;

    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),

<<<<<<< HEAD
<<<<<<< HEAD
      /// 🔻 BOTTOM BAR
=======
      /// 🔻 BOTTOM BAR (Responsive + Safe)
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
      /// BOTTOM BAR
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(8),
          height: 70,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
<<<<<<< HEAD

                  // ✅ ONLY ADD CART HERE
                 onPressed: () async {
  try {
    await addToCart();

    if (!mounted) return;

    // ✅ Chuyển sang màn hình giỏ hàng
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Shoppingcar()),
    );
  } catch (e) {
    print("❌ ADD TO CART ERROR: $e");
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Lỗi: $e")),
    );
  }
},

                  child: const Icon(Icons.add_shopping_cart),
                ),
              ),

              const SizedBox(width: 10),

=======
                  onPressed: () {},
                  child: const Icon(Icons.add_shopping_cart),
                ),
              ),
              const SizedBox(width: 10),
>>>>>>> 4d9c391 (apply new gitignore rules)
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Mua ngay"),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
<<<<<<< HEAD
<<<<<<< HEAD
            /// HEADER
=======
            /// 🔻 HEADER
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
            /// HEADER
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Icon(Icons.shopping_bag_outlined),
                  const SizedBox(width: 10),
                  const Icon(Icons.notifications_none),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
<<<<<<< HEAD
                    /// IMAGE
                    AspectRatio(
                      aspectRatio: 1,
=======
                    /// 🔻 IMAGE (FIX FULL RESPONSIVE)
                    AspectRatio(
                      aspectRatio: 1, // luôn vuông, đẹp mọi màn
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
                    /// IMAGE
                    AspectRatio(
                      aspectRatio: 1,
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)
                      child: Container(
                        color: Colors.white,
                        child: product!.images.isEmpty
                            ? const Center(
<<<<<<< HEAD
                                child: Icon(Icons.image_not_supported),
=======
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
>>>>>>> 4d9c391 (apply new gitignore rules)
                              )
                            : PageView(
                                children: product!.images.map((img) {
                                  return Image.network(
                                    "${AppConfig.apiUrl}/$img",
<<<<<<< HEAD
                                    fit: BoxFit.cover,
<<<<<<< HEAD
=======
=======
                                    fit: BoxFit.contain,
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)

                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image),
                                    ),

                                    loadingBuilder:
                                        (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child:
                                            CircularProgressIndicator(),
                                      );
                                    },
>>>>>>> 4d9c391 (apply new gitignore rules)
                                  );
                                }).toList(),
                              ),
                      ),
                    ),

<<<<<<< HEAD
<<<<<<< HEAD
                    /// INFO
=======
                    /// 🔻 INFO
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
                    /// INFO
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
<<<<<<< HEAD
                          Row(
                            children: [
                              Text(
                                "${variant?.price ?? product!.minPrice} đ",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
=======
                          /// PRICE
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "${variant?.price ?? product!.minPrice} đ",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
>>>>>>> 4d9c391 (apply new gitignore rules)
                                ),
                              ),
                              const Spacer(),
                              const Text("Đã bán: 0"),
                            ],
                          ),

                          const SizedBox(height: 8),

<<<<<<< HEAD
                          Text(product!.name),

                          const SizedBox(height: 16),

=======
                          /// NAME
                          Text(
                            product!.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const SizedBox(height: 16),

<<<<<<< HEAD
                          /// 🔥 ATTRIBUTES
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
                          /// ATTRIBUTES
>>>>>>> 667b85e (update UI Home and ProductDetail Screen)
                          ...product!.attributes.map((attr) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
<<<<<<< HEAD
                                Text(attr.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
=======
                                Text(
                                  attr.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
>>>>>>> 4d9c391 (apply new gitignore rules)
                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 8,
<<<<<<< HEAD
=======
                                  runSpacing: 8,
>>>>>>> 4d9c391 (apply new gitignore rules)
                                  children: attr.values.map((value) {
                                    final isSelected =
                                        selectedAttributes[attr.name] ==
                                            value;

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedAttributes[attr.name] =
                                              value;
                                        });
                                      },
                                      child: Container(
<<<<<<< HEAD
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
=======
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
>>>>>>> 4d9c391 (apply new gitignore rules)
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
<<<<<<< HEAD
=======
                                          color: isSelected
                                              ? Colors.red[50]
                                              : Colors.grey[200],
>>>>>>> 4d9c391 (apply new gitignore rules)
                                        ),
                                        child: Text(value),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),

                          const Divider(),

<<<<<<< HEAD
                          Text(
                            "Kho: ${variant != null && variant.stockQuantity > 0 ? "Còn hàng" : "Hết hàng"}",
=======
                          buildRow(
                            "Kho",
                            variant != null && variant.stockQuantity > 0
                                ? "Còn hàng"
                                : "Hết hàng",
>>>>>>> 4d9c391 (apply new gitignore rules)
                          ),

                          const Divider(),

<<<<<<< HEAD
                          Text(product!.description),
=======
                          /// DESCRIPTION
                          Text(
                            product!.description,
                            style: const TextStyle(color: Colors.black87),
                          ),
>>>>>>> 4d9c391 (apply new gitignore rules)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
=======

  Widget buildRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(left)),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
>>>>>>> 4d9c391 (apply new gitignore rules)
}