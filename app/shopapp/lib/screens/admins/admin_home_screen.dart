import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> products = [
    Product(id: 1, name: "Iphone 15", price: 2000),
    Product(id: 2, name: "Samsung S24", price: 1800),
    Product(id: 3, name: "Xiaomi 14", price: 1200),
  ];

  void deleteProduct(int id) {
    setState(() {
      products.removeWhere((p) => p.id == id);
    });
  }

  void editProduct(Product product) {
    // TODO: điều hướng sang màn hình edit
    print("Edit: ${product.name}");
  }

  void addProduct() {
    // TODO: điều hướng sang màn hình thêm
    print("Add new product");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product List"),
      ),

      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text("\$${product.price}"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => editProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteProduct(product.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}