import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          CircleAvatar(radius: 18, backgroundColor: Colors.blue),

          Spacer(),

          Icon(Icons.shopping_bag_outlined),

          SizedBox(width: 16),

          Icon(Icons.notifications_none),
        ],
      ),
    );
  }
}
