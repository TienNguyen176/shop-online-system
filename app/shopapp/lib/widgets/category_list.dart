import 'package:flutter/material.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

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
