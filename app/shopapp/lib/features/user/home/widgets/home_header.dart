import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../../../widgets/cart_item_badge.dart';
import '../../notification/providers/notification_provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  /// Xay dung giao dien hien thi cho widget.
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
          const _NotificationIconWithBadge(),
          const CartIconWithBadge(),
        ],
      ),
    );
  }
}

class _NotificationIconWithBadge extends StatelessWidget {
  const _NotificationIconWithBadge();

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, _) {
        final count = provider.unreadCount;

        return Stack(
          children: [
            IconButton(
              tooltip: "Thong bao",
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
            if (count > 0)
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffef4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 16),
                  child: Text(
                    count > 99 ? "99+" : "$count",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
