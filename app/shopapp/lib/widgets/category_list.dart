import 'package:flutter/material.dart';
import '../models/category.dart';
import '../repositories/i_category_repository.dart';

class CategoryList extends StatefulWidget {
  final ICategoryRepository repo;
  final Function(int categoryId) onSelected;

  const CategoryList({super.key, required this.repo, required this.onSelected});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selected = 0;
  List<Category> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final data = await widget.repo.getCategories();

    setState(() {
      categories = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selected == index;

          return GestureDetector(
            onTap: () {
              setState(() => selected = index);

              final categoryId = categories[index].id;

              widget.onSelected(categoryId);
              
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              alignment: Alignment.center,
              
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index].name,
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
