import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/attribute_model.dart';
import '../../attribute/providers/attribute_provider.dart';
import '../../models/admin_product_model.dart';
import '../models/admin_product_variant.dart';
import '../providers/product_admin_provider.dart';

class ProductVariantManagementScreen extends StatefulWidget {
  final AdminProduct product;

  const ProductVariantManagementScreen({super.key, required this.product});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<ProductVariantManagementScreen> createState() =>
      _ProductVariantManagementScreenState();
}

class _ProductVariantManagementScreenState
    extends State<ProductVariantManagementScreen> {
  static const _pageBg = Color(0xFFF3F4F6);
  static const _border = Color(0xFFE5E7EB);
  static const _muted = Color(0xFF6B7280);

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<AttributeProvider>().loadAttributes();
      if (!mounted) return;
      await context.read<ProductAdminProvider>().loadVariants(widget.product.id);
    });
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductAdminProvider>();

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(title: Text("Biến thể: ${widget.product.name}")),
      body: SafeArea(
        child:
            provider.loading && provider.variants.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh:
                      () => context.read<ProductAdminProvider>().loadVariants(
                        widget.product.id,
                      ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final horizontalPadding = width >= 900 ? 24.0 : 16.0;
                      final maxContentWidth = width >= 1200 ? 1120.0 : width;
                      final useGrid = width >= 760;
                      final variants = provider.variants;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child:
                              variants.isEmpty
                                  ? ListView(
                                    padding: EdgeInsets.fromLTRB(
                                      horizontalPadding,
                                      24,
                                      horizontalPadding,
                                      96,
                                    ),
                                    children: [
                                      _EmptyVariants(
                                        productName: widget.product.name,
                                        onAdd: () => _showVariantSheet(),
                                      ),
                                    ],
                                  )
                                  : CustomScrollView(
                                    slivers: [
                                      SliverPadding(
                                        padding: EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          16,
                                          horizontalPadding,
                                          12,
                                        ),
                                        sliver: SliverToBoxAdapter(
                                          child: _VariantSummary(
                                            productName: widget.product.name,
                                            count: variants.length,
                                          ),
                                        ),
                                      ),
                                      SliverPadding(
                                        padding: EdgeInsets.fromLTRB(
                                          horizontalPadding,
                                          0,
                                          horizontalPadding,
                                          96,
                                        ),
                                        sliver:
                                            useGrid
                                                ? SliverGrid(
                                                  gridDelegate:
                                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                                        maxCrossAxisExtent: 520,
                                                        mainAxisExtent: 190,
                                                        mainAxisSpacing: 12,
                                                        crossAxisSpacing: 12,
                                                      ),
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                        (context, index) {
                                                          final variant =
                                                              variants[index];
                                                          return _VariantCard(
                                                            variant: variant,
                                                            onEdit:
                                                                () =>
                                                                    _showVariantSheet(
                                                                      variant:
                                                                          variant,
                                                                    ),
                                                            onDelete:
                                                                () =>
                                                                    _confirmDelete(
                                                                      variant,
                                                                    ),
                                                          );
                                                        },
                                                        childCount:
                                                            variants.length,
                                                      ),
                                                )
                                                : SliverList(
                                                  delegate:
                                                      SliverChildBuilderDelegate(
                                                        (context, index) {
                                                          final itemIndex =
                                                              index ~/ 2;
                                                          if (index.isOdd) {
                                                            return const SizedBox(
                                                              height: 12,
                                                            );
                                                          }

                                                          final variant =
                                                              variants[itemIndex];
                                                          return _VariantCard(
                                                            variant: variant,
                                                            onEdit:
                                                                () =>
                                                                    _showVariantSheet(
                                                                      variant:
                                                                          variant,
                                                                    ),
                                                            onDelete:
                                                                () =>
                                                                    _confirmDelete(
                                                                      variant,
                                                                    ),
                                                          );
                                                        },
                                                        childCount:
                                                            variants.length *
                                                                2 -
                                                            1,
                                                      ),
                                                ),
                                      ),
                                    ],
                                  ),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showVariantSheet(),
        icon: const Icon(Icons.add),
        label: const Text("Thêm biến thể"),
      ),
    );
  }

  /// Hien thi xac nhan truoc khi thuc hien hanh dong.
  Future<void> _confirmDelete(AdminProductVariant variant) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Xác nhận"),
            content: const Text("Xóa biến thể này?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Hủy"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Xóa"),
              ),
            ],
          ),
    );

    if (confirm != true || !mounted) return;

    try {
      await context.read<ProductAdminProvider>().deleteVariant(
        widget.product.id,
        variant.id,
      );
      if (!mounted) return;
      _showMessage("Xóa biến thể thành công");
    } catch (e) {
      if (!mounted) return;
      _showMessage("Xóa biến thể thất bại: $e");
    }
  }

  /// Xu ly logic cho ham _showVariantSheet.
  Future<void> _showVariantSheet({AdminProductVariant? variant}) async {
    final priceCtrl = TextEditingController(
      text: variant == null ? "" : variant.price.toStringAsFixed(0),
    );
    final stockCtrl = TextEditingController(
      text: variant?.stockQuantity.toString() ?? "",
    );
    final skuCtrl = TextEditingController(text: variant?.sku ?? "");
    final rows =
        variant?.attributes.entries
            .map(
              (entry) => _VariantAttributeRow(
                attributeName: entry.key,
                value: entry.value,
              ),
            )
            .toList() ??
        <_VariantAttributeRow>[];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder:
          (sheetContext) => StatefulBuilder(
            builder: (context, setSheetState) {
              final attributes = context.watch<AttributeProvider>().attributes;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 720;

                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          0,
                          16,
                          MediaQuery.of(context).viewInsets.bottom + 16,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                variant == null
                                    ? "Thêm biến thể"
                                    : "Sửa biến thể",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 14),
                              if (isWide)
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: priceCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: _input("Giá"),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        controller: stockCtrl,
                                        keyboardType: TextInputType.number,
                                        decoration: _input("Số lượng tồn"),
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                TextField(
                                  controller: priceCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _input("Giá"),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: stockCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: _input("Số lượng tồn"),
                                ),
                              ],
                              const SizedBox(height: 10),
                              TextField(
                                controller: skuCtrl,
                                decoration: _input("SKU (có thể để trống)"),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      "Thuộc tính biến thể",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      setSheetState(() {
                                        rows.add(_VariantAttributeRow());
                                      });
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text("Thêm"),
                                  ),
                                ],
                              ),
                              if (rows.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    "Chưa có thuộc tính nào cho biến thể này.",
                                    style: TextStyle(color: _muted),
                                  ),
                                ),
                              ...rows.map(
                                (row) => _buildAttributeRow(
                                  row,
                                  attributes,
                                  setSheetState,
                                  rows,
                                ),
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await _saveVariant(
                                        variant,
                                        priceCtrl,
                                        stockCtrl,
                                        skuCtrl,
                                        rows,
                                      );
                                      if (!mounted) return;
                                      _showMessage(
                                        variant == null
                                            ? "Thêm biến thể thành công"
                                            : "Cập nhật biến thể thành công",
                                      );
                                      if (sheetContext.mounted) {
                                        Navigator.pop(sheetContext);
                                      }
                                    } catch (e) {
                                      if (!mounted) return;
                                      _showMessage(
                                        variant == null
                                            ? "Thêm biến thể thất bại: $e"
                                            : "Cập nhật biến thể thất bại: $e",
                                      );
                                    }
                                  },
                                  child: const Text("Lưu biến thể"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );

    priceCtrl.dispose();
    stockCtrl.dispose();
    skuCtrl.dispose();
  }

  /// Xu ly logic cho ham _buildAttributeRow.
  Widget _buildAttributeRow(
    _VariantAttributeRow row,
    List<AttributeModel> attributes,
    StateSetter setSheetState,
    List<_VariantAttributeRow> rows,
  ) {
    AttributeModel? selectedAttribute;
    for (final attribute in attributes) {
      if (attribute.name == row.attributeName) {
        selectedAttribute = attribute;
        break;
      }
    }

    final values = selectedAttribute?.values ?? <String>[];
    final valueExists = values.contains(row.value);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        final attributeField = DropdownButtonFormField<String>(
          value: selectedAttribute == null ? null : row.attributeName,
          isExpanded: true,
          decoration: _input("Thuộc tính"),
          items:
              attributes
                  .map(
                    (attribute) => DropdownMenuItem<String>(
                      value: attribute.name,
                      child: Text(
                        attribute.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: (value) {
            setSheetState(() {
              row.attributeName = value;
              row.value = null;
            });
          },
        );
        final valueField = DropdownButtonFormField<String>(
          value: valueExists ? row.value : null,
          isExpanded: true,
          decoration: _input("Giá trị"),
          items:
              values
                  .map(
                    (value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
          onChanged:
              values.isEmpty
                  ? null
                  : (value) {
                    setSheetState(() {
                      row.value = value;
                    });
                  },
        );
        final removeButton = IconButton(
          tooltip: "Xóa thuộc tính",
          onPressed: () {
            setSheetState(() {
              rows.remove(row);
            });
          },
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child:
              compact
                  ? Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: attributeField),
                          removeButton,
                        ],
                      ),
                      const SizedBox(height: 10),
                      valueField,
                    ],
                  )
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: attributeField),
                      const SizedBox(width: 10),
                      Expanded(child: valueField),
                      removeButton,
                    ],
                  ),
        );
      },
    );
  }

  /// Luu du lieu tu form hoac state hien tai.
  Future<void> _saveVariant(
    AdminProductVariant? variant,
    TextEditingController priceCtrl,
    TextEditingController stockCtrl,
    TextEditingController skuCtrl,
    List<_VariantAttributeRow> rows,
  ) async {
    final attributes = <String, String>{};
    for (final row in rows) {
      if (row.attributeName != null && row.value != null) {
        attributes[row.attributeName!] = row.value!;
      }
    }

    final data = {
      "price": double.tryParse(priceCtrl.text.trim()) ?? 0,
      "stockQuantity": int.tryParse(stockCtrl.text.trim()) ?? 0,
      "sku": skuCtrl.text.trim().isEmpty ? null : skuCtrl.text.trim(),
      "attributes": attributes,
    };

    await context.read<ProductAdminProvider>().saveVariant(
      productId: widget.product.id,
      variant: variant,
      data: data,
    );
  }

  /// Xu ly logic cho ham _input.
  InputDecoration _input(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// Hien thi thong bao nhanh cho nguoi dung.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _VariantAttributeRow {
  String? attributeName;
  String? value;

  _VariantAttributeRow({this.attributeName, this.value});
}

class _VariantSummary extends StatelessWidget {
  final String productName;
  final int count;

  const _VariantSummary({
    required this.productName,
    required this.count,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ProductVariantManagementScreenState._border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "$count biến thể",
                  style: const TextStyle(
                    color: _ProductVariantManagementScreenState._muted,
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

class _EmptyVariants extends StatelessWidget {
  final String productName;
  final VoidCallback onAdd;

  const _EmptyVariants({
    required this.productName,
    required this.onAdd,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 420),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _ProductVariantManagementScreenState._border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.tune_outlined,
                  size: 30,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                productName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sản phẩm chưa có biến thể",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ProductVariantManagementScreenState._muted,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: const Text("Thêm biến thể"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VariantCard extends StatelessWidget {
  final AdminProductVariant variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VariantCard({
    required this.variant,
    required this.onEdit,
    required this.onDelete,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final title =
        variant.sku?.isNotEmpty == true
            ? variant.sku!
            : "Biến thể #${variant.id}";
    final attributes =
        variant.attributes.entries
            .map((entry) => "${entry.key}: ${entry.value}")
            .toList();
    final visibleAttributes = attributes.take(4).toList();
    if (attributes.length > visibleAttributes.length) {
      visibleAttributes.add("+${attributes.length - visibleAttributes.length}");
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _ProductVariantManagementScreenState._border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              PopupMenuButton<_VariantAction>(
                tooltip: "Tùy chọn",
                onSelected: (action) {
                  switch (action) {
                    case _VariantAction.edit:
                      onEdit();
                      break;
                    case _VariantAction.delete:
                      onDelete();
                      break;
                  }
                },
                itemBuilder:
                    (context) => const [
                      PopupMenuItem(
                        value: _VariantAction.edit,
                        child: ListTile(
                          dense: true,
                          leading: Icon(Icons.edit_outlined),
                          title: Text("Sửa"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: _VariantAction.delete,
                        child: ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          title: Text("Xóa"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.sell_outlined,
                label: "Giá",
                value: variant.price.toStringAsFixed(0),
              ),
              _InfoChip(
                icon: Icons.warehouse_outlined,
                label: "Tồn kho",
                value: variant.stockQuantity.toString(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (attributes.isEmpty)
            const Text(
              "Chưa có thuộc tính",
              style: TextStyle(
                color: _ProductVariantManagementScreenState._muted,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  visibleAttributes
                      .map((text) => _AttributePill(text: text))
                      .toList(),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(
            "$label: ",
            style: const TextStyle(
              color: _ProductVariantManagementScreenState._muted,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AttributePill extends StatelessWidget {
  final String text;

  const _AttributePill({required this.text});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum _VariantAction { edit, delete }
