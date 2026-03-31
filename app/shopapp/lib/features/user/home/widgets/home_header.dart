import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/admin');
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),

          const Spacer(),

          const Icon(Icons.shopping_bag_outlined),

          const SizedBox(width: 16),

          const Icon(Icons.notifications_none),
        ],
      ),
    );
  }
}
