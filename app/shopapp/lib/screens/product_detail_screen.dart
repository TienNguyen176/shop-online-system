import 'package:flutter/material.dart';
import 'package:shopapp/repositories/cart_repository.dart';
import 'package:shopapp/screens/shoppingcar.dart';
import '../repositories/i_product_repository.dart';
import '../models/product_detail.dart';
import '../models/product_variant.dart';
import '../config/app_config.dart';

final CartRepository cartRepo = CartRepository();

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

      /// 🔻 BOTTOM BAR
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
            /// HEADER
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
                    /// IMAGE
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: Colors.white,
                        child: product!.images.isEmpty
                            ? const Center(
                                child: Icon(Icons.image_not_supported),
                              )
                            : PageView(
                                children: product!.images.map((img) {
                                  return Image.network(
                                    "${AppConfig.apiUrl}/$img",
                                    fit: BoxFit.cover,
                                  );
                                }).toList(),
                              ),
                      ),
                    ),

                    /// INFO
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "${variant?.price ?? product!.minPrice} đ",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              const Text("đã bán: 2"),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Text(product!.name),

                          const SizedBox(height: 16),

                          ...product!.attributes.map((attr) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(attr.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 8,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
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

                          Text(
                            "Kho: ${variant != null && variant.stockQuantity > 0 ? "Còn hàng" : "Hết hàng"}",
                          ),

                          const Divider(),

                          Text(product!.description),
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
}