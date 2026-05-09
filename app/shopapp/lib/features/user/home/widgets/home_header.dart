import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../oderstus/orderstatus.dart';

import '../../../../widgets/cart_item_badge.dart';

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

          /// icon đơn hàng
          GestureDetector(
            onTap: () async {
              // Lấy userId từ AuthProvider thay vì SecureStorage
              final auth = Provider.of<AuthProvider>(context, listen: false);

              if (!auth.isLoggedIn || auth.user == null) {
                print("Chưa login");
                return;
              }

              final userId = auth.user!['id'];
              print("userId: $userId");

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => Orderstatus(
                        userId:
                            userId is int
                                ? userId
                                : int.parse(userId.toString()),
                      ),
                ),
              );
            },
            child: const Icon(
              Icons.receipt_long,
              size: 28,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 16),

          const CartIconWithBadge(),

          const SizedBox(width: 16),

          const Icon(Icons.notifications_none),
        ],
      ),
    );
  }
}
