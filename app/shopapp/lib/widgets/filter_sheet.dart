import 'package:flutter/material.dart';
import '../models/product_filter.dart';

class FilterSheet extends StatefulWidget {
  final List<String> brands;
  final List<String> sizes;
  final List<String> colors;
  final List<String> selectedSizes;
  final List<String> selectedColors;

  const FilterSheet({
    super.key,
    required this.brands,
    this.sizes = const [],
    this.colors = const [],
    this.selectedSizes = const [],
    this.selectedColors = const [],
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late List<String> selectedBrands;
  late List<String> selectedColors;
  late List<String> selectedSizes;

  final minCtrl = TextEditingController();
  final maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedBrands = [];
    selectedColors = List.from(widget.selectedColors);
    selectedSizes = List.from(widget.selectedSizes);
  }

  Widget buildChip(String label, List<String> selected) {
    final isSelected = selected.contains(label);

    return ChoiceChip(
      label: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
          )),
      selected: isSelected,
      selectedColor: Colors.blueAccent,
      backgroundColor: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onSelected: (_) {
        setState(() {
          if (isSelected) {
            selected.remove(label);
          } else {
            selected.add(label);
          }
        });
      },
    );
  }

  Widget section(String title, List<String> items, List<String> selected) {
    if (items.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((e) => buildChip(e, selected)).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Container(
              width: 50,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Bộ lọc",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Filters
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    section("Thương hiệu", widget.brands, selectedBrands),
                    section("Size", widget.sizes, selectedSizes),
                    section("Màu sắc", widget.colors, selectedColors),

                    // Price Range
                    const Text("Khoảng giá",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: minCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Giá từ",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: maxCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Đến",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Huỷ"),
                  ),
                ),
                const SizedBox(width: 12),
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
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Áp dụng"),
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