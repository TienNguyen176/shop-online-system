import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/user_address.dart';
import '../services/address_service.dart';
import '../widgets/address_form_sheet.dart';

/// Màn hình hồ sơ: hiển thị thông tin tài khoản và quản lý địa chỉ giao hàng.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const primary = Color(0xff2563eb);
  static const primarySoft = Color(0xffdbeafe);
  static const bg = Color(0xffeef2fb);
  static const textDark = Color(0xff1f2937);
  static const textMuted = Color(0xff6b7280);

  final AddressService _addressService = AddressService();
  final List<UserAddress> _addresses = [];

  bool _loadedAddresses = false;
  bool _loadingAddresses = false;

  /// Lấy giá trị text đầu tiên tồn tại trong user theo danh sách key truyền vào.
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

  /// Tải danh sách địa chỉ đã lưu của người dùng.
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
        backgroundColor: bg,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: textDark,
          title: const Text("Hồ sơ"),
        ),
        body: Center(
          child: ElevatedButton.icon(
            onPressed:
                () => Navigator.pushReplacementNamed(context, AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.login_rounded),
            label: const Text("Đăng nhập"),
          ),
        ),
      );
    }

    final name = _text(user, ["fullName", "name", "full_name"]);
    final email = _text(user, ["email"]);
    final avatar = _text(user, ["avatar", "picture"]);
    final role = _text(user, ["role"]);
    final displayName = name.isNotEmpty ? name : "User";

    return Scaffold(
      backgroundColor: bg,
      body: RefreshIndicator(
        color: primary,
        onRefresh: _loadAddresses,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: primary,
              foregroundColor: Colors.white,
              title: const Text("Hồ sơ"),
              actions: [
                IconButton(
                  tooltip: "Làm mới",
                  onPressed: _loadAddresses,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ProfileHeader(
                    name: displayName,
                    email: email,
                    avatar: avatar,
                    role: role,
                    addressCount: _addresses.length,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      children: [
                        _InfoSection(
                          userId: user["id"]?.toString() ?? "",
                          name: displayName,
                          email: email,
                          role: role,
                        ),
                        const SizedBox(height: 14),
                        _AddressSection(
                          addresses: _addresses,
                          loading: _loadingAddresses,
                          onAdd: () => _openAddressForm(),
                          onEdit: _openAddressForm,
                          onDelete: _confirmDeleteAddress,
                        ),
                        const SizedBox(height: 14),
                        _LogoutButton(onPressed: () => _logout(context)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mở form thêm/sửa địa chỉ và tải lại danh sách sau khi lưu thành công.
  Future<void> _openAddressForm([UserAddress? address]) async {
    final saved = await showModalBottomSheet<UserAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => AddressFormSheet(
            service: _addressService,
            address: address,
            accentColor: primary,
          ),
    );

    if (saved != null) {
      await _loadAddresses();
    }
  }

  /// Hiển thị hộp thoại xác nhận trước khi xóa địa chỉ.
  Future<void> _confirmDeleteAddress(UserAddress address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: const Text("Xóa địa chỉ?"),
            content: Text(
              address.fullAddress.isNotEmpty
                  ? address.fullAddress
                  : "Bạn có chắc muốn xóa địa chỉ này?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Xóa"),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _deleteAddress(address);
    }
  }

  /// Gọi API xóa địa chỉ và cập nhật lại danh sách địa chỉ.
  Future<void> _deleteAddress(UserAddress address) async {
    try {
      await _addressService.deleteAddress(address.id);
      await _loadAddresses();
      _showMessage("Đã xóa địa chỉ");
    } catch (e) {
      _showMessage("Không thể xóa địa chỉ");
    }
  }

  /// Đăng xuất, xóa session/giỏ hàng và đưa người dùng về màn login.
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

  /// Hiển thị thông báo ngắn bằng SnackBar.
  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String avatar;
  final String role;
  final int addressCount;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.avatar,
    required this.role,
    required this.addressCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _ProfileScreenState.primary,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: _ProfileScreenState.primarySoft,
              backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
              child:
                  avatar.isEmpty
                      ? const Icon(
                        Icons.person,
                        size: 48,
                        color: _ProfileScreenState.primary,
                      )
                      : null,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                email,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xffbfdbfe)),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Row(
              children: [
                Expanded(
                  child: _HeaderMetric(
                    icon: Icons.verified_user_outlined,
                    label: "Vai trò",
                    value: role.isNotEmpty ? role : "user",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _HeaderMetric(
                    icon: Icons.location_on_outlined,
                    label: "Địa chỉ",
                    value: "$addressCount",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeaderMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xffbfdbfe),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final String role;

  const _InfoSection({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.account_circle_outlined,
            title: "Thông tin tài khoản",
          ),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.badge_outlined, label: "ID", value: userId),
          _InfoRow(icon: Icons.person_outline, label: "Tên", value: name),
          _InfoRow(icon: Icons.email_outlined, label: "Email", value: email),
          _InfoRow(
            icon: Icons.verified_user_outlined,
            label: "Vai trò",
            value: role,
            showDivider: false,
          ),
        ],
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
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: _SectionTitle(
                  icon: Icons.location_on_outlined,
                  title: "Địa chỉ giao hàng",
                ),
              ),
              IconButton.filledTonal(
                tooltip: "Thêm địa chỉ",
                onPressed: onAdd,
                icon: const Icon(Icons.add_location_alt_outlined),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: CircularProgressIndicator(
                  color: _ProfileScreenState.primary,
                ),
              ),
            )
          else if (addresses.isEmpty)
            _EmptyAddresses(onAdd: onAdd)
          else
            ...addresses.map(
              (address) => _AddressCard(
                address: address,
                onEdit: () => onEdit(address),
                onDelete: () => onDelete(address),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final UserAddress address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AddressCard({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              address.isDefault
                  ? _ProfileScreenState.primary.withOpacity(0.35)
                  : const Color(0xffe5e7eb),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  address.isDefault
                      ? _ProfileScreenState.primarySoft
                      : const Color(0xfff3f4f6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              address.isDefault
                  ? Icons.location_on
                  : Icons.location_on_outlined,
              color:
                  address.isDefault
                      ? _ProfileScreenState.primary
                      : _ProfileScreenState.textMuted,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        address.receiverName.isNotEmpty
                            ? address.receiverName
                            : "Người nhận",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ProfileScreenState.textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (address.isDefault) const _DefaultBadge(),
                  ],
                ),
                if (address.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: const TextStyle(
                      color: _ProfileScreenState.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (address.fullAddress.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    address.fullAddress,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ProfileScreenState.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    _TextAction(
                      icon: Icons.edit_outlined,
                      label: "Sửa",
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _TextAction(
                      icon: Icons.delete_outline,
                      label: "Xóa",
                      destructive: true,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  final Widget child;

  const _Surface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffdbeafe)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1d4ed8).withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _ProfileScreenState.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _ProfileScreenState.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: _ProfileScreenState.textMuted, size: 20),
              const SizedBox(width: 12),
              SizedBox(
                width: 72,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _ProfileScreenState.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value.isNotEmpty ? value : "Chưa có thông tin",
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: _ProfileScreenState.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xffe5e7eb)),
      ],
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyAddresses({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xfff8fbff),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffdbeafe)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.add_location_alt_outlined,
            color: _ProfileScreenState.textMuted,
            size: 34,
          ),
          const SizedBox(height: 8),
          const Text(
            "Chưa có địa chỉ giao hàng",
            style: TextStyle(
              color: _ProfileScreenState.textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text("Thêm địa chỉ"),
          ),
        ],
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _ProfileScreenState.primarySoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        "Mặc định",
        style: TextStyle(
          color: _ProfileScreenState.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TextAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback onPressed;

  const _TextAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        destructive ? const Color(0xFFDC2626) : _ProfileScreenState.primary;

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(icon, size: 17),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LogoutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          side: const BorderSide(color: Color(0xFFFECACA)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          "Đăng xuất",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}