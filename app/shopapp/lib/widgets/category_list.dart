import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
<<<<<<< HEAD
  final Function(String)? onCategorySelected;
  final int selectedIndex;

  const CategoryList({super.key, this.onCategorySelected, this.selectedIndex = 0});
=======
  const CategoryList({super.key});
>>>>>>> 4d9c391 (apply new gitignore rules)

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
<<<<<<< HEAD
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
=======
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16),

        itemCount: categories.length,

        itemBuilder: (context, index) {
          bool isSelected = selected == index;

>>>>>>> 4d9c391 (apply new gitignore rules)
          return GestureDetector(
            onTap: () {
              setState(() {
                selected = index;
              });
<<<<<<< HEAD
              widget.onCategorySelected?.call(categories[index]);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
=======
            },

            child: Container(
              margin: const EdgeInsets.only(right: 12),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

>>>>>>> 4d9c391 (apply new gitignore rules)
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
<<<<<<< HEAD
=======

>>>>>>> 4d9c391 (apply new gitignore rules)
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 4d9c391 (apply new gitignore rules)
