import 'package:flutter/material.dart';

import '../../../../routes/app_routes.dart';
import '../../../../widgets/cart_item_badge.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff1d4ed8).withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              "assets/icon.jpg",
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            "NEXT4SHOP",
            style: TextStyle(
              color: Color(0xff1f2937),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: "Thông báo",
            visualDensity: VisualDensity.compact,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.notifications);
            },
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: Color(0xff1f2937),
            ),
          ),
          const CartIconWithBadge(),
        ],
      ),
    );
  }
}
