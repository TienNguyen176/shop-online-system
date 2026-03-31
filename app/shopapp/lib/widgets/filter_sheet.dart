import 'package:flutter/material.dart';
import '../models/product_filter.dart';

class FilterSheet extends StatefulWidget {
  final List<String> brands;
  final List<String> sizes;
  final List<String> colors;

  const FilterSheet({
    super.key,
    required this.brands,
    this.sizes = const [],
    this.colors = const [], required List<String> selectedSizes, required List<String> selectedColors,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  List<String> selectedBrands = [];
  List<String> selectedColors = [];
  List<String> selectedSizes = [];

  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();

  List<String> get colors => widget.colors;
  List<String> get sizes => widget.sizes;

  Widget buildChip(String label, List<String> selected) {
    final isSelected = selected.contains(label);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue,
      onSelected: (_) {
        setState(() {
          isSelected ? selected.remove(label) : selected.add(label);
        });
      },
    );
  }

  Widget section(String title, List<String> items, List<String> selected) {
    if (items.isEmpty) return const SizedBox(); // nếu không có items thì ẩn section
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: items.map((e) => buildChip(e, selected)).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text("Bộ lọc", style: TextStyle(fontSize: 18)),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  section("Thương hiệu", widget.brands, selectedBrands),
                  section("Size", sizes, selectedSizes),
                  section("Màu sắc", colors, selectedColors),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: minCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Giá từ",
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: maxCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Đến",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Huỷ"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      ProductFilter(
                        brands: selectedBrands,
                        colors: selectedColors,
                        sizes: selectedSizes,
                        minPrice: double.tryParse(minCtrl.text),
                        maxPrice: double.tryParse(maxCtrl.text),
                      ),
                    );
                  },
                  child: const Text("Áp dụng"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}