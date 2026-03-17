import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
<<<<<<< HEAD
  final VoidCallback? onFilter; // 👈 THÊM DÒNG NÀY
=======
>>>>>>> 4d9c391 (apply new gitignore rules)

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
<<<<<<< HEAD
    this.onFilter, // 👈 THÊM DÒNG NÀY
=======
>>>>>>> 4d9c391 (apply new gitignore rules)
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,

              onChanged: onChanged,

              textAlignVertical: TextAlignVertical.center,

              decoration: InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                prefixIcon: const Icon(Icons.search),

                filled: true,
                fillColor: Colors.blue[100],

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),

                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(width: 10),

<<<<<<< HEAD
          IconButton(
  icon: const Icon(Icons.filter_alt_outlined),
  onPressed: onFilter,
),
=======
          const Icon(Icons.filter_alt_outlined, size: 28),
>>>>>>> 4d9c391 (apply new gitignore rules)
        ],
      ),
    );
  }
}
