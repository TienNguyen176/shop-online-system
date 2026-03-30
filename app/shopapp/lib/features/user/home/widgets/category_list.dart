import 'package:flutter/material.dart';
import '../../../../models/category.dart';
import '../../../../repositories/interfaces/i_category_repository.dart';

class CategoryList extends StatefulWidget {
<<<<<<< HEAD
<<<<<<< HEAD
  final Function(String)? onCategorySelected;
  final int selectedIndex;

  const CategoryList({super.key, this.onCategorySelected, this.selectedIndex = 0});
=======
  const CategoryList({super.key});
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
  final ICategoryRepository repo;
  final Function(int categoryId) onSelected;

  const CategoryList({super.key, required this.repo, required this.onSelected});
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)

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

>>>>>>> 4d9c391 (apply new gitignore rules)
          return GestureDetector(
            onTap: () {
<<<<<<< HEAD
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
=======
              setState(() => selected = index);
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)

              final categoryId = categories[index].id;

              widget.onSelected(categoryId);
              
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

<<<<<<< HEAD
>>>>>>> 4d9c391 (apply new gitignore rules)
=======
              alignment: Alignment.center,
              
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
<<<<<<< HEAD
<<<<<<< HEAD
=======

>>>>>>> 4d9c391 (apply new gitignore rules)
=======
>>>>>>> 4caf251 (Add SplashScreen, Setup Build APK, Update API,NET)
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
<<<<<<< HEAD
}
=======
}
>>>>>>> 4d9c391 (apply new gitignore rules)
