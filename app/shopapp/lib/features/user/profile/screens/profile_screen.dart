import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../routes/app_routes.dart';
import '../../auth/providers/auth_provider.dart';
import '../../cart/providers/cart_provider.dart';
import '../models/location_option.dart';
import '../models/user_address.dart';
import '../services/address_service.dart';

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
      _showMessage("Khong the tai dia chi");
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
            _ProfileTile(icon: Icons.person_outline, label: "Ten", value: name),
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
                  "Dang xuat",
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
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (_) => _AddressFormSheet(
            service: _addressService,
            address: address,
          ),
    );

    if (saved == true) {
      await _loadAddresses();
    }
  }

  Future<void> _deleteAddress(UserAddress address) async {
    try {
      await _addressService.deleteAddress(address.id);
      await _loadAddresses();
      _showMessage("Da xoa dia chi");
    } catch (e) {
      _showMessage("Khong the xoa dia chi");
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
                "Dia chi giao hang",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ),
            IconButton(
              tooltip: "Them dia chi",
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
              "Chua co dia chi",
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
                      : "Nguoi nhan",
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    [
                      if (address.phone.isNotEmpty) address.phone,
                      if (address.fullAddress.isNotEmpty) address.fullAddress,
                      if (address.isDefault) "Mac dinh",
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
                        PopupMenuItem(value: "edit", child: Text("Sua")),
                        PopupMenuItem(value: "delete", child: Text("Xoa")),
                      ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddressFormSheet extends StatefulWidget {
  final AddressService service;
  final UserAddress? address;

  const _AddressFormSheet({
    required this.service,
    this.address,
  });

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _receiverCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _lineCtrl = TextEditingController();

  List<LocationOption> _provinces = [];
  List<LocationOption> _districts = [];
  List<LocationOption> _wards = [];

  LocationOption? _province;
  LocationOption? _district;
  LocationOption? _ward;
  bool _isDefault = false;
  bool _loadingLocations = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _receiverCtrl.text = address.receiverName;
      _phoneCtrl.text = address.phone;
      _lineCtrl.text = address.addressLine;
      _isDefault = address.isDefault;
    }
    _loadInitialLocations();
  }

  @override
  void dispose() {
    _receiverCtrl.dispose();
    _phoneCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialLocations() async {
    try {
      final provinces = await widget.service.getProvinces();
      final address = widget.address;

      List<LocationOption> districts = [];
      List<LocationOption> wards = [];
      LocationOption? province;
      LocationOption? district;
      LocationOption? ward;

      if (address?.provinceId != null) {
        province = LocationOption(
          id: address!.provinceId.toString(),
          name: address.provinceName,
        );
        districts = await widget.service.getDistricts(address.provinceId!);
      }

      if (address?.districtId != null) {
        district = LocationOption(
          id: address!.districtId.toString(),
          name: address.districtName,
        );
        wards = await widget.service.getWards(address.districtId!);
      }

      if (address != null && address.wardCode.isNotEmpty) {
        ward = LocationOption(id: address.wardCode, name: address.wardName);
      }

      if (!mounted) return;
      final provinceItems = _mergeSelected(provinces, province);
      final districtItems = _mergeSelected(districts, district);
      final wardItems = _mergeSelected(wards, ward);
      setState(() {
        _provinces = provinceItems;
        _districts = districtItems;
        _wards = wardItems;
        _province = _selectedFrom(provinceItems, province);
        _district = _selectedFrom(districtItems, district);
        _ward = _selectedFrom(wardItems, ward);
        _loadingLocations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingLocations = false);
      _showMessage("Khong the tai du lieu dia chi GHN");
    }
  }

  List<LocationOption> _mergeSelected(
    List<LocationOption> options,
    LocationOption? selected,
  ) {
    if (selected == null || selected.id.isEmpty) return options;
    if (options.any((item) => item.id == selected.id)) return options;
    return [selected, ...options];
  }

  LocationOption? _selectedFrom(
    List<LocationOption> options,
    LocationOption? selected,
  ) {
    if (selected == null) return null;
    for (final option in options) {
      if (option.id == selected.id) return option;
    }
    return selected;
  }

  Future<void> _onProvinceChanged(LocationOption? value) async {
    setState(() {
      _province = value;
      _district = null;
      _ward = null;
      _districts = [];
      _wards = [];
    });

    final provinceId = int.tryParse(value?.id ?? "");
    if (provinceId == null) return;

    final districts = await widget.service.getDistricts(provinceId);
    if (!mounted) return;
    setState(() => _districts = districts);
  }

  Future<void> _onDistrictChanged(LocationOption? value) async {
    setState(() {
      _district = value;
      _ward = null;
      _wards = [];
    });

    final districtId = int.tryParse(value?.id ?? "");
    if (districtId == null) return;

    final wards = await widget.service.getWards(districtId);
    if (!mounted) return;
    setState(() => _wards = wards);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_province == null || _district == null || _ward == null) {
      _showMessage("Vui long chon tinh, quan/huyen, phuong/xa");
      return;
    }

    final request = {
      "receiverName": _receiverCtrl.text.trim(),
      "phone": _phoneCtrl.text.trim(),
      "addressLine": _lineCtrl.text.trim(),
      "provinceId": int.parse(_province!.id),
      "provinceName": _province!.name,
      "districtId": int.parse(_district!.id),
      "districtName": _district!.name,
      "wardCode": _ward!.id,
      "wardName": _ward!.name,
      "isDefault": _isDefault,
    };

    try {
      setState(() => _saving = true);
      final id = widget.address?.id;
      if (id == null) {
        await widget.service.createAddress(request);
      } else {
        await widget.service.updateAddress(id, request);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showMessage("Khong the luu dia chi");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child:
          _loadingLocations
              ? const SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator()),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.address == null
                                  ? "Them dia chi"
                                  : "Sua dia chi",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _receiverCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nguoi nhan",
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "So dien thoai",
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lineCtrl,
                        decoration: const InputDecoration(
                          labelText: "So nha, ten duong",
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      _LocationDropdown(
                        label: "Tinh/Thanh pho",
                        value: _province,
                        items: _provinces,
                        onChanged: _onProvinceChanged,
                      ),
                      const SizedBox(height: 12),
                      _LocationDropdown(
                        label: "Quan/Huyen",
                        value: _district,
                        items: _districts,
                        onChanged:
                            _province == null ? null : _onDistrictChanged,
                      ),
                      const SizedBox(height: 12),
                      _LocationDropdown(
                        label: "Phuong/Xa",
                        value: _ward,
                        items: _wards,
                        onChanged:
                            _district == null
                                ? null
                                : (value) => setState(() => _ward = value),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _isDefault,
                        onChanged: (value) => setState(() => _isDefault = value),
                        title: const Text("Dat lam dia chi mac dinh"),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          icon:
                              _saving
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(Icons.save_outlined),
                          label: const Text("Luu dia chi"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? "Bat buoc" : null;
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

class _LocationDropdown extends StatelessWidget {
  final String label;
  final LocationOption? value;
  final List<LocationOption> items;
  final ValueChanged<LocationOption?>? onChanged;

  const _LocationDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LocationOption>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem<LocationOption>(
                  value: item,
                  child: Text(item.name, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? "Bat buoc" : null,
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
