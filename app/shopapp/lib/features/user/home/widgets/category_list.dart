import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../admin/category/providers/category_provider.dart';

class CategoryList extends StatefulWidget {
  final Function(int categoryId) onSelected;

  const CategoryList({super.key, required this.onSelected});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  int selectedCategoryId = 0;

  static const List<IconData> _icons = [
    Icons.category_outlined,
    Icons.event_seat_outlined,
    Icons.lightbulb_outline,
    Icons.weekend_outlined,
    Icons.inventory_2_outlined,
    Icons.home_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 104,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final categories = provider.categories;

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategoryId == cat.id;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedCategoryId = cat.id);
                  widget.onSelected(cat.id);
                },
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? const Color(0xff2563eb)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          _icons[index % _icons.length],
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xff475569),
                          size: 23,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 30,
                        child: Text(
                          cat.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                isSelected
                                    ? const Color(0xff2563eb)
                                    : const Color(0xff64748b),
                            fontSize: 11,
                            height: 1.15,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
