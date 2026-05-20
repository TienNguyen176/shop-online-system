import 'package:flutter/material.dart';

import '../models/location_option.dart';
import '../models/user_address.dart';
import '../services/address_service.dart';

class AddressFormSheet extends StatefulWidget {
  final AddressService service;
  final UserAddress? address;
  final bool initialDefault;
  final bool showDefaultSwitch;
  final String? title;
  final String submitLabel;
  final Color? accentColor;

  const AddressFormSheet({
    super.key,
    required this.service,
    this.address,
    this.initialDefault = false,
    this.showDefaultSwitch = true,
    this.title,
    this.submitLabel = "Lưu địa chỉ",
    this.accentColor,
  });

  /// Tao state quan ly vong doi cua widget.
  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
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

  Color get _accent => widget.accentColor ?? Theme.of(context).primaryColor;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address != null) {
      _receiverCtrl.text = address.receiverName;
      _phoneCtrl.text = address.phone;
      _lineCtrl.text = address.addressLine;
      _isDefault = address.isDefault;
    } else {
      _isDefault = widget.initialDefault;
    }
    _loadInitialLocations();
  }

  /// Giai phong controller, listener va tai nguyen khi widget bi huy.
  @override
  void dispose() {
    _receiverCtrl.dispose();
    _phoneCtrl.dispose();
    _lineCtrl.dispose();
    super.dispose();
  }

  /// Tai du lieu can thiet cho _loadInitialLocations.
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
      _showMessage("Không thể tải dữ liệu địa chỉ GHN");
    }
  }

  /// Xu ly logic cho ham _mergeSelected.
  List<LocationOption> _mergeSelected(
    List<LocationOption> options,
    LocationOption? selected,
  ) {
    if (selected == null || selected.id.isEmpty) return options;
    if (options.any((item) => item.id == selected.id)) return options;
    return [selected, ...options];
  }

  /// Cap nhat lua chon hien tai cua nguoi dung.
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

  /// Xu ly logic cho ham _onProvinceChanged.
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

    try {
      final districts = await widget.service.getDistricts(provinceId);
      if (!mounted) return;
      setState(() => _districts = districts);
    } catch (e) {
      _showMessage("Không thể tải quận/huyện");
    }
  }

  /// Xu ly logic cho ham _onDistrictChanged.
  Future<void> _onDistrictChanged(LocationOption? value) async {
    setState(() {
      _district = value;
      _ward = null;
      _wards = [];
    });

    final districtId = int.tryParse(value?.id ?? "");
    if (districtId == null) return;

    try {
      final wards = await widget.service.getWards(districtId);
      if (!mounted) return;
      setState(() => _wards = wards);
    } catch (e) {
      _showMessage("Không thể tải phường/xã");
    }
  }

  /// Luu du lieu tu form hoac state hien tai.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_province == null || _district == null || _ward == null) {
      _showMessage("Vui lòng chọn đầy đủ địa chỉ");
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
      final saved =
          id == null
              ? await widget.service.createAddress(request)
              : await widget.service.updateAddress(id, request);
      if (!mounted) return;
      Navigator.pop(context, saved);
    } catch (e) {
      _showMessage("Không thể lưu địa chỉ");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Xay dung giao dien hien thi cho widget.
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
              ? SizedBox(
                height: 220,
                child: Center(child: CircularProgressIndicator(color: _accent)),
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
                              widget.title ??
                                  (widget.address == null
                                      ? "Thêm địa chỉ"
                                      : "Sửa địa chỉ"),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
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
                          labelText: "Người nhận",
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Số điện thoại",
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lineCtrl,
                        decoration: const InputDecoration(
                          labelText: "Số nhà, tên đường",
                          border: OutlineInputBorder(),
                        ),
                        validator: _required,
                      ),
                      const SizedBox(height: 12),
                      _LocationDropdown(
                        label: "Tỉnh/Thành phố",
                        value: _province,
                        items: _provinces,
                        onChanged: _onProvinceChanged,
                      ),
                      const SizedBox(height: 12),
                      _LocationDropdown(
                        label: "Quận/Huyện",
                        value: _district,
                        items: _districts,
                        onChanged:
                            _province == null ? null : _onDistrictChanged,
                      ),
                      const SizedBox(height: 12),
                      _LocationDropdown(
                        label: "Phường/Xã",
                        value: _ward,
                        items: _wards,
                        onChanged:
                            _district == null
                                ? null
                                : (value) => setState(() => _ward = value),
                      ),
                      if (widget.showDefaultSwitch) ...[
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _isDefault,
                          activeColor: _accent,
                          onChanged:
                              (value) => setState(() => _isDefault = value),
                          title: const Text("Đặt làm địa chỉ mặc định"),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
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
                          label: Text(
                            widget.submitLabel,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  /// Kiem tra gia tri bat buoc trong form.
  String? _required(String? value) {
    return value == null || value.trim().isEmpty ? "Bắt buộc" : null;
  }

  /// Hien thi thong bao nhanh cho nguoi dung.
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

  /// Xay dung giao dien hien thi cho widget.
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
      validator: (value) => value == null ? "Bắt buộc" : null,
    );
  }
}
