import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_product_model.dart';
import '../providers/product_admin_provider.dart';
import '../widgets/admin_product_card.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String keyword = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductAdminProvider>().loadProducts();
    });

    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final provider = context.read<ProductAdminProvider>();

    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        !provider.loading &&
        !provider.isFetching &&
        provider.hasMore) {
      provider.loadProducts();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductAdminProvider>(
      builder: (context, provider, _) {
        final data =
            keyword.isEmpty
                ? provider.products
                : provider.products
                    .where(
                      (p) =>
                          p.name.toLowerCase().contains(keyword.toLowerCase()),
                    )
                    .toList();

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// SEARCH + ADD
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() => keyword = value);
                      },
                      decoration: InputDecoration(
                        hintText: "Search product...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(
                    onPressed: () async {
                      final provider = context.read<ProductAdminProvider>();

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductFormScreen(),
                        ),
                      );

                      if (!mounted) return;

                      if (result != null && result is AdminProduct) {
                        provider.loadProducts(refresh: true);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add"),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// LIST
              Expanded(
                child:
                    provider.loading && provider.products.isEmpty
                        ? const Center(child: CircularProgressIndicator())
                        : data.isEmpty
                        ? const Center(child: Text("No products found"))
                        : ListView.builder(
                          controller: scrollController,
                          itemCount: data.length + (provider.hasMore ? 1 : 0),

                          itemBuilder: (context, i) {
                            if (i >= data.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final product = data[i];

                            return AdminProductCard(
                              product: product,

                              /// EDIT
                              onEdit: () async {
                                final provider =
                                    context.read<ProductAdminProvider>();

                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            ProductFormScreen(product: product),
                                  ),
                                );

                                if (!mounted) return;

                                if (result != null) {
                                  provider.loadProducts(refresh: true);
                                }
                              },

                              /// DELETE
                              onDelete: () async {
                                final provider =
                                    context.read<ProductAdminProvider>();

                                final confirm = await showDialog(
                                  context: context,
                                  builder:
                                      (_) => AlertDialog(
                                        title: const Text("Confirm"),
                                        content: const Text(
                                          "Delete this product?",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  false,
                                                ),
                                            child: const Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(
                                                  context,
                                                  true,
                                                ),
                                            child: const Text("Delete"),
                                          ),
                                        ],
                                      ),
                                );

                                if (!mounted) return;

                                if (confirm == true) {
                                  await provider.deleteProduct(product.id);

                                  if (!mounted) return;

                                  provider.loadProducts(refresh: true);
                                }
                              },
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
