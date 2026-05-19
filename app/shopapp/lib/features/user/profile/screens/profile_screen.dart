import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _text(Map<String, dynamic> user, List<String> keys) {
    for (final key in keys) {
      final value = user[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Ho so")),
        body: Center(
          child: ElevatedButton(
            onPressed:
                () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: const Text("Dang nhap"),
          ),
        ),
      );
    }

    final name = _text(user, ["fullName", "name", "full_name"]);
    final email = _text(user, ["email"]);
    final avatar = _text(user, ["avatar", "picture"]);
    final role = _text(user, ["role"]);

    return Scaffold(
      appBar: AppBar(title: const Text("Ho so")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child:
                  avatar.isEmpty
                      ? const Icon(Icons.person, size: 48, color: Colors.blue)
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              name.isNotEmpty ? name : "User",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 6),
            Center(
              child: Text(
                email,
                style: TextStyle(color: Colors.grey.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _ProfileTile(
            icon: Icons.badge_outlined,
            label: "ID",
            value: user["id"]?.toString() ?? "",
          ),
          _ProfileTile(
            icon: Icons.person_outline,
            label: "Ten",
            value: name,
          ),
          _ProfileTile(
            icon: Icons.email_outlined,
            label: "Email",
            value: email,
          ),
          _ProfileTile(
            icon: Icons.verified_user_outlined,
            label: "Vai tro",
            value: role,
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xffdc2626),
                side: const BorderSide(color: Color(0xfffecaca)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                "Dang xuat",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    context.read<CartProvider>().clearCart();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value.isNotEmpty ? value : "Chua co thong tin"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
