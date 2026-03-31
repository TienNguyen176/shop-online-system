import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  final Function(String)? onCategorySelected;
  final int selectedIndex;

  const CategoryList({super.key, this.onCategorySelected, this.selectedIndex = 0});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selected = 0;

  final List<String> categories = [
    "Tất cả",
    "Áo thun",
    "Áo khoác",
    "Giày",
    "Quần",
  ];

  @override
  void initState() {
    super.initState();
    selected = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(CategoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      setState(() => selected = widget.selectedIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selected == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selected = index;
              });
              widget.onCategorySelected?.call(categories[index]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}