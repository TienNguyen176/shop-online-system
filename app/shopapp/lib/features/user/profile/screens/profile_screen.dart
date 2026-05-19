import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/user_address.dart';
import '../services/address_service.dart';
import '../widgets/address_form_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AddressService _addressService = AddressService();
  final List<UserAddress> _addresses = [];

  bool _loadedAddresses = false;
  bool _loadingAddresses = false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedAddresses && context.read<AuthProvider>().isLoggedIn) {
      _loadedAddresses = true;
      _loadAddresses();
    }
  }

  Future<void> _loadAddresses() async {
    try {
      setState(() => _loadingAddresses = true);
      final data = await _addressService.getAddresses();
      if (!mounted) return;
      setState(() {
        _addresses
          ..clear()
          ..addAll(data);
      });
    } catch (e) {
      _showMessage("Không thể tải địa chỉ");
    } finally {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Hồ sơ")),
        body: Center(
          child: ElevatedButton(
            onPressed:
                () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            child: const Text("Đăng nhập"),
          ),
        ),
      );
    }

    final name = _text(user, ["fullName", "name", "full_name"]);
    final email = _text(user, ["email"]);
    final avatar = _text(user, ["avatar", "picture"]);
    final role = _text(user, ["role"]);

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ")),
      body: RefreshIndicator(
        onRefresh: _loadAddresses,
        child: ListView(
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
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
            _ProfileTile(icon: Icons.person_outline, label: "Tên", value: name),
            _ProfileTile(
              icon: Icons.email_outlined,
              label: "Email",
              value: email,
            ),
            _ProfileTile(
              icon: Icons.verified_user_outlined,
              label: "Vai trò",
              value: role,
            ),
            const SizedBox(height: 18),
            _AddressSection(
              addresses: _addresses,
              loading: _loadingAddresses,
              onAdd: () => _openAddressForm(),
              onEdit: _openAddressForm,
              onDelete: _deleteAddress,
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
                  "Đăng xuất",
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddressForm([UserAddress? address]) async {
    final saved = await showModalBottomSheet<UserAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (_) => AddressFormSheet(
            service: _addressService,
            address: address,
          ),
    );

    if (saved != null) {
      await _loadAddresses();
    }
  }

  Future<void> _deleteAddress(UserAddress address) async {
    try {
      await _addressService.deleteAddress(address.id);
      await _loadAddresses();
      _showMessage("Đã xóa địa chỉ");
    } catch (e) {
      _showMessage("Không thể xóa địa chỉ");
    }
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }
}

class _AddressSection extends StatelessWidget {
  final List<UserAddress> addresses;
  final bool loading;
  final VoidCallback onAdd;
  final ValueChanged<UserAddress> onEdit;
  final ValueChanged<UserAddress> onDelete;

  const _AddressSection({
    required this.addresses,
    required this.loading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Địa chỉ giao hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: "Thêm địa chỉ",
              onPressed: onAdd,
              icon: const Icon(Icons.add_location_alt_outlined),
            ),
          ],
        ),
        if (loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (addresses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "Chưa có địa chỉ",
              style: TextStyle(color: Colors.grey.shade700),
            ),
          )
        else
          ...addresses.map(
            (address) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListTile(
                leading: Icon(
                  address.isDefault
                      ? Icons.location_on
                      : Icons.location_on_outlined,
                  color:
                      address.isDefault
                          ? const Color(0xff2563eb)
                          : Colors.grey.shade700,
                ),
                title: Text(
                  address.receiverName.isNotEmpty
                      ? address.receiverName
                      : "Người nhận",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [
                      if (address.phone.isNotEmpty) address.phone,
                      if (address.fullAddress.isNotEmpty) address.fullAddress,
                      if (address.isDefault) "Mặc định",
                    ].join("\n"),
                  ),
                ),
                isThreeLine: true,
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "edit") onEdit(address);
                    if (value == "delete") onDelete(address);
                  },
                  itemBuilder:
                      (_) => const [
                        PopupMenuItem(value: "edit", child: Text("Sửa")),
                        PopupMenuItem(value: "delete", child: Text("Xóa")),
                      ],
                ),
              ),
            ),
          ),
      ],
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
      subtitle: Text(value.isNotEmpty ? value : "Chưa có thông tin"),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
