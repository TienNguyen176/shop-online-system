import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../models/checkout_request.dart';
import '../../../../models/order_item.dart';
import '../../profile/models/user_address.dart';
import '../../profile/services/address_service.dart';
import '../../profile/widgets/address_form_sheet.dart';
import '../providers/payment_provider.dart';
import 'payment_webview_screen.dart';

class PaymentScreen extends StatefulWidget {
  final CheckoutRequest request;

  const PaymentScreen({super.key, required this.request});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const shopee = Color(0xffee4d2d);
  static const bg = Color(0xfff5f5f5);
  static const textDark = Color(0xff222222);
  static const textMuted = Color(0xff757575);
  static const border = Color(0xffeeeeee);

  final AddressService _addressService = AddressService();
  final List<UserAddress> _addresses = [];

  UserAddress? _selectedAddress;
  int _method = 2;
  bool _loadingAddresses = true;
  bool _loadingShippingFee = false;
  double _shippingFee = 0;

  double get _subtotal => widget.request.items.fold(
    0.0,
    (sum, item) => sum + item.price * item.quantity,
  );

  int get _totalQuantity => widget.request.items.fold(
    0,
    (sum, item) => sum + item.quantity,
  );

  double get _grandTotal => _subtotal + _shippingFee;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAddresses());
  }

  /// Tai du lieu can thiet cho _loadAddresses.
  Future<void> _loadAddresses() async {
    try {
      setState(() => _loadingAddresses = true);
      final data = await _addressService.getAddresses();
      if (!mounted) return;

      setState(() {
        _addresses
          ..clear()
          ..addAll(data);
        _selectedAddress = _defaultAddressFrom(data);
      });

      final selected = _selectedAddress;
      if (selected != null) {
        await _loadShippingFee(selected);
      }
    } catch (e) {
      _showMessage("Không thể tải địa chỉ giao hàng");
    } finally {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  /// Xu ly logic cho ham _defaultAddressFrom.
  UserAddress? _defaultAddressFrom(List<UserAddress> addresses) {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  /// Tai du lieu can thiet cho _loadShippingFee.
  Future<void> _loadShippingFee(UserAddress address) async {
    final districtId = address.districtId;
    if (districtId == null || address.wardCode.isEmpty) {
      setState(() => _shippingFee = 0);
      return;
    }

    try {
      setState(() => _loadingShippingFee = true);
      final fee = await _addressService.getShippingFee(
        toDistrictId: districtId,
        toWardCode: address.wardCode,
        insuranceValue: _subtotal,
        quantity: _totalQuantity,
      );
      if (!mounted) return;
      setState(() => _shippingFee = fee);
    } catch (e) {
      if (!mounted) return;
      setState(() => _shippingFee = 0);
      _showMessage("Không thể tính phí vận chuyển");
    } finally {
      if (mounted) setState(() => _loadingShippingFee = false);
    }
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentProvider>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          "Thanh toán",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            color: shopee,
            onRefresh: _loadAddresses,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 138),
              children: [
                _AddressCard(
                  loading: _loadingAddresses,
                  address: _selectedAddress,
                  onTap: _openAddressPicker,
                ),
                const SizedBox(height: 10),
                _ProductSection(items: widget.request.items),
                const SizedBox(height: 10),
                _PaymentMethodCard(
                  method: _method,
                  onChanged: (value) => setState(() => _method = value),
                ),
                const SizedBox(height: 10),
                _SummaryCard(
                  subtotal: _subtotal,
                  shippingFee: _shippingFee,
                  loadingShippingFee: _loadingShippingFee,
                  totalQuantity: _totalQuantity,
                ),
              ],
            ),
          ),
          _BottomCheckoutBar(
            loading: provider.loading,
            total: _grandTotal,
            onCheckout:
                _selectedAddress == null || _loadingShippingFee
                    ? null
                    : _checkout,
          ),
        ],
      ),
    );
  }

  /// Mo man hinh hoac hop thoai lien quan.
  Future<void> _openAddressPicker() async {
    if (_loadingAddresses) return;

    if (_addresses.isEmpty) {
      await _openAddressForm();
      return;
    }

    final selected = await showModalBottomSheet<UserAddress>(
      context: context,
      backgroundColor: Colors.white,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder:
          (_) => _AddressPickerSheet(
            addresses: _addresses,
            selectedAddress: _selectedAddress,
            onAddAddress: _openAddressForm,
          ),
    );

    if (selected != null) {
      setState(() => _selectedAddress = selected);
      await _loadShippingFee(selected);
    }
  }

  /// Mo man hinh hoac hop thoai lien quan.
  Future<UserAddress?> _openAddressForm() async {
    final created = await showModalBottomSheet<UserAddress>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      builder:
          (_) => AddressFormSheet(
            service: _addressService,
            initialDefault: _addresses.isEmpty,
            showDefaultSwitch: false,
            title: "Thêm địa chỉ nhận hàng",
            submitLabel: "Lưu và dùng địa chỉ này",
            accentColor: shopee,
          ),
    );

    if (created == null) return null;

    setState(() {
      _addresses.add(created);
      _selectedAddress = created;
    });
    await _loadShippingFee(created);
    return created;
  }

  /// Thuc hien quy trinh thanh toan don hang.
  Future<void> _checkout() async {
    final address = _selectedAddress;
    if (address == null) {
      _showMessage("Vui lòng chọn địa chỉ giao hàng");
      return;
    }

    final updatedRequest = CheckoutRequest(
      userId: widget.request.userId,
      amount: _grandTotal,
      name: address.receiverName,
      orderType: "billpayment",
      orderDescription: "Thanh toán đơn hàng",
      items: widget.request.items,
      shippingName: address.receiverName,
      shippingPhone: address.phone,
      shippingAddress: address.fullAddress,
    );

    await context.read<PaymentProvider>().checkout(updatedRequest);
    if (!mounted) return;

    final url = context.read<PaymentProvider>().paymentUrl;
    if (url != null && url.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PaymentWebViewScreen(url: url)),
      );
    }
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

class _AddressCard extends StatelessWidget {
  final bool loading;
  final UserAddress? address;
  final VoidCallback onTap;

  const _AddressCard({
    required this.loading,
    required this.address,
    required this.onTap,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final selectedAddress = address;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffee4d2d),
                    Color(0xffee4d2d),
                    Color(0xff2563eb),
                    Color(0xff2563eb),
                  ],
                  stops: [0, 0.45, 0.45, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child:
                  loading
                      ? const SizedBox(
                        height: 68,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _PaymentScreenState.shopee,
                          ),
                        ),
                      )
                      : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: _PaymentScreenState.shopee,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child:
                                selectedAddress == null
                                    ? const Text(
                                      "Chọn địa chỉ giao hàng",
                                      style: TextStyle(
                                        color: _PaymentScreenState.textDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    )
                                    : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Địa chỉ nhận hàng",
                                          style: TextStyle(
                                            color: _PaymentScreenState.shopee,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${selectedAddress.receiverName}  ${selectedAddress.phone}",
                                          style: const TextStyle(
                                            color: _PaymentScreenState.textDark,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          selectedAddress.fullAddress,
                                          style: const TextStyle(
                                            color: _PaymentScreenState.textDark,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductSection extends StatelessWidget {
  final List<OrderItem> items;

  const _ProductSection({required this.items});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const ListTile(
            dense: true,
            leading: Icon(Icons.storefront_outlined, color: Colors.black87),
            title: Text(
              "Next4Shop",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const Divider(height: 1, color: _PaymentScreenState.border),
          ...items.map((item) => _ProductTile(item: item)),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final OrderItem item;

  const _ProductTile({required this.item});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _PaymentScreenState.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _ProductImage(imageUrl: _imageUrl(item.image)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _PaymentScreenState.textDark,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (item.variantName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.variantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _PaymentScreenState.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${_formatPrice(item.price)}đ",
                      style: const TextStyle(
                        color: _PaymentScreenState.shopee,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      "x${item.quantity}",
                      style: const TextStyle(
                        color: _PaymentScreenState.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
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

  /// Dinh dang gia tien de hien thi tren giao dien.
  String _formatPrice(num price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }

  /// Tao URL day du cho duong dan hinh anh.
  String? _imageUrl(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
      return trimmed;
    }

    final cleanApi = AppConfig.apiUrl.replaceAll(RegExp(r"/+$"), "");
    final cleanPath = trimmed.replaceAll(RegExp(r"^/+"), "");
    return "$cleanApi/$cleanPath";
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;

  const _ProductImage({required this.imageUrl});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) return _fallback();

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (_, __) => _loading(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  /// Hien thi trang thai dang tai du lieu.
  Widget _loading() {
    return const Center(
      child: SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _PaymentScreenState.shopee,
        ),
      ),
    );
  }

  /// Hien thi giao dien thay the khi khong tai duoc du lieu.
  Widget _fallback() {
    return const Center(
      child: Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final int method;
  final ValueChanged<int> onChanged;

  const _PaymentMethodCard({
    required this.method,
    required this.onChanged,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.payments_outlined),
            title: Text(
              "Phương thức thanh toán",
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          _PaymentOptionTile(
            value: 2,
            groupValue: method,
            assetPath: "assets/vnpay_logo.jpg",
            title: "VNPay",
            subtitle: "Thanh toán qua cổng VNPay",
            onChanged: onChanged,
          ),
          _PaymentOptionTile(
            value: 3,
            groupValue: method,
            assetPath: "assets/momo_logo.jpg",
            title: "MoMo",
            subtitle: "Sắp hỗ trợ",
            onChanged: null,
          ),
        ],
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  final int value;
  final int groupValue;
  final String assetPath;
  final String title;
  final String subtitle;
  final ValueChanged<int>? onChanged;

  const _PaymentOptionTile({
    required this.value,
    required this.groupValue,
    required this.assetPath,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return InkWell(
      onTap: enabled ? () => onChanged!(value) : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(
          children: [
            _PaymentLogo(assetPath: assetPath, enabled: enabled),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color:
                          enabled
                              ? _PaymentScreenState.textDark
                              : _PaymentScreenState.textMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: _PaymentScreenState.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Radio<int>(
              value: value,
              groupValue: groupValue,
              activeColor: _PaymentScreenState.shopee,
              onChanged: enabled ? (selected) => onChanged!(selected!) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentLogo extends StatelessWidget {
  final String assetPath;
  final bool enabled;

  const _PaymentLogo({
    required this.assetPath,
    required this.enabled,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        width: 46,
        height: 34,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _PaymentScreenState.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder:
              (_, __, ___) => const Icon(
                Icons.payments_outlined,
                color: _PaymentScreenState.textMuted,
                size: 20,
              ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final bool loadingShippingFee;
  final int totalQuantity;

  const _SummaryCard({
    required this.subtotal,
    required this.shippingFee,
    required this.loadingShippingFee,
    required this.totalQuantity,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: "Tổng tiền hàng ($totalQuantity sản phẩm)",
            value: "${_formatPrice(subtotal)}đ",
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: "Phí vận chuyển",
            value:
                loadingShippingFee
                    ? "Đang tính..."
                    : "${_formatPrice(shippingFee)}đ",
          ),
          const Divider(height: 24, color: _PaymentScreenState.border),
          _SummaryRow(
            label: "Tổng thanh toán",
            value: "${_formatPrice(subtotal + shippingFee)}đ",
            strong: true,
          ),
        ],
      ),
    );
  }

  /// Dinh dang gia tien de hien thi tren giao dien.
  String _formatPrice(num price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color:
                  strong
                      ? _PaymentScreenState.textDark
                      : _PaymentScreenState.textMuted,
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                strong
                    ? _PaymentScreenState.shopee
                    : _PaymentScreenState.textDark,
            fontSize: strong ? 18 : 14,
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BottomCheckoutBar extends StatelessWidget {
  final bool loading;
  final double total;
  final VoidCallback? onCheckout;

  const _BottomCheckoutBar({
    required this.loading,
    required this.total,
    required this.onCheckout,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Tổng thanh toán",
                      style: TextStyle(
                        color: _PaymentScreenState.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${_formatPrice(total)}đ",
                      style: const TextStyle(
                        color: _PaymentScreenState.shopee,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loading ? null : onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _PaymentScreenState.shopee,
                    disabledBackgroundColor: const Color(0xffd1d5db),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child:
                      loading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text(
                            "Đặt hàng",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dinh dang gia tien de hien thi tren giao dien.
  String _formatPrice(num price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => '.');
  }
}

class _AddressPickerSheet extends StatelessWidget {
  final List<UserAddress> addresses;
  final UserAddress? selectedAddress;
  final Future<UserAddress?> Function() onAddAddress;

  const _AddressPickerSheet({
    required this.addresses,
    required this.selectedAddress,
    required this.onAddAddress,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Chọn địa chỉ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final created = await onAddAddress();
                if (created != null) {
                  navigator.pop(created);
                }
              },
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text(
                "Thêm địa chỉ mới",
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _PaymentScreenState.shopee,
                side: const BorderSide(color: _PaymentScreenState.shopee),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: addresses.length,
              separatorBuilder:
                  (_, __) => const Divider(
                    height: 1,
                    color: _PaymentScreenState.border,
                  ),
              itemBuilder: (_, index) {
                final address = addresses[index];
                final selected = address.id == selectedAddress?.id;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color:
                        selected
                            ? _PaymentScreenState.shopee
                            : Colors.grey,
                  ),
                  title: Text(
                    "${address.receiverName}  ${address.phone}",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(address.fullAddress),
                  trailing:
                      address.isDefault
                          ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _PaymentScreenState.shopee,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "Mặc định",
                              style: TextStyle(
                                color: _PaymentScreenState.shopee,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                          : null,
                  onTap: () => Navigator.pop(context, address),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
