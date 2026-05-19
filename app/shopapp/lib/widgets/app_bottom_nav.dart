import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/user/auth/providers/auth_provider.dart';
import '../features/user/order_status/screens/order_status_screen.dart';
import '../routes/app_routes.dart';

enum AppBottomNavItem { home, product, order, profile }

class AppBottomNav extends StatelessWidget {
  final AppBottomNavItem activeItem;

  const AppBottomNav({super.key, required this.activeItem});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1d4ed8).withOpacity(0.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              icon: Icons.home_rounded,
              label: "Trang chủ",
              active: activeItem == AppBottomNavItem.home,
              onTap: () => _goHome(context),
            ),
            _NavButton(
              icon: Icons.shopping_bag_outlined,
              label: "Sản phẩm",
              active: activeItem == AppBottomNavItem.product,
              onTap: () => _goProduct(context),
            ),
            _NavButton(
              icon: Icons.receipt_long_outlined,
              label: "Đơn hàng",
              active: activeItem == AppBottomNavItem.order,
              onTap: () => _goOrder(context),
            ),
            _NavButton(
              icon: Icons.person_outline_rounded,
              label: "Hồ sơ",
              active: activeItem == AppBottomNavItem.profile,
              onTap: () => _goProfile(context),
            ),
          ],
        ),
      ),
    );
  }

  void _goHome(BuildContext context) {
    if (activeItem == AppBottomNavItem.home) return;
    Navigator.pushReplacementNamed(context, AppRoutes.userHome);
  }

  void _goProduct(BuildContext context) {
    if (activeItem == AppBottomNavItem.product) return;
    Navigator.pushNamed(context, AppRoutes.userProducts);
  }

  void _goProfile(BuildContext context) {
    if (activeItem == AppBottomNavItem.profile) return;
    Navigator.pushNamed(context, AppRoutes.userProfile);
  }

  void _goOrder(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    final id = user?["id"];
    final userId = id is int ? id : int.tryParse(id?.toString() ?? "");

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để xem đơn hàng")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderStatusScreen(userId: userId)),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xff2563eb) : const Color(0xff9ca3af);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: active ? FontWeight.w800 : FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
