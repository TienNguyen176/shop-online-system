import 'package:flutter/material.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
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

          const Icon(Icons.filter_alt_outlined, size: 28),
        ],
      ),
    );
  }
}
