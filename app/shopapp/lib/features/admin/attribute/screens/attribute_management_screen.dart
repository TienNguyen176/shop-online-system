import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/attribute_model.dart';
import '../providers/attribute_provider.dart';

class AttributeManagementScreen extends StatefulWidget {
  const AttributeManagementScreen({super.key});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<AttributeManagementScreen> createState() =>
      _AttributeManagementScreenState();
}

class _AttributeManagementScreenState extends State<AttributeManagementScreen> {
  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttributeProvider>().loadAttributes(refresh: true);
    });
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Consumer<AttributeProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xfff3f4f6),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(provider),
            icon: const Icon(Icons.add),
            label: const Text("Thêm thuộc tính"),
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.loadAttributes(refresh: true),
            child:
                provider.isLoading && provider.attributes.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      children: [
                        _Header(
                          title: "Quản lý thuộc tính",
                          subtitle: "${provider.attributes.length} thuộc tính",
                        ),
                        const SizedBox(height: 12),
                        if (provider.attributes.isEmpty)
                          const _EmptyState(message: "Chưa có thuộc tính")
                        else
                          ...provider.attributes.map(
                            (attribute) => _AttributeTile(
                              attribute: attribute,
                              onEdit: () => _openForm(provider, attribute),
                              onDelete: () => _confirmDelete(
                                provider,
                                attribute,
                              ),
                            ),
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  /// Mo man hinh hoac hop thoai lien quan.
  Future<void> _openForm(
    AttributeProvider provider, [
    AttributeModel? attribute,
  ]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _AttributeFormSheet(
        provider: provider,
        attribute: attribute,
      ),
    );

    if (saved == true && mounted) {
      _showMessage(
        attribute == null
            ? "Thêm thuộc tính thành công"
            : "Cập nhật thuộc tính thành công",
      );
    }
  }

  /// Hien thi xac nhan truoc khi thuc hien hanh dong.
  Future<void> _confirmDelete(
    AttributeProvider provider,
    AttributeModel attribute,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa thuộc tính?"),
        content: Text("Bạn có chắc muốn xóa '${attribute.name}' không?"),
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

    if (ok != true) return;

    try {
      await provider.deleteAttribute(attribute.id);
      if (mounted) _showMessage("Xóa thuộc tính thành công");
    } catch (e) {
      if (mounted) _showMessage("Xóa thuộc tính thất bại: $e");
    }
  }

  /// Hien thi thong bao nhanh cho nguoi dung.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _AttributeFormSheet extends StatefulWidget {
  final AttributeProvider provider;
  final AttributeModel? attribute;

  const _AttributeFormSheet({
    required this.provider,
    this.attribute,
  });

  /// Tao state quan ly vong doi cua widget.
  @override
  State<_AttributeFormSheet> createState() => _AttributeFormSheetState();
}

class _AttributeFormSheetState extends State<_AttributeFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final List<String> _values = [];
  bool _saving = false;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    final attribute = widget.attribute;
    if (attribute != null) {
      _nameCtrl.text = attribute.name;
      _values.addAll(attribute.values);
    }
  }

  /// Giai phong controller, listener va tai nguyen khi widget bi huy.
  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
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
                      widget.attribute == null
                          ? "Thêm thuộc tính"
                          : "Sửa thuộc tính",
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Tên thuộc tính",
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _valueCtrl,
                      decoration: const InputDecoration(
                        labelText: "Giá trị",
                        hintText: "VD: Đỏ, XL, 128GB",
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: (_) => _addValue(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 56,
                    child: FilledButton(
                      onPressed: _addValue,
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._values.map(
                    (value) => InputChip(
                      label: Text(value),
                      onDeleted: () {
                        setState(() => _values.remove(value));
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    widget.attribute == null
                        ? "Thêm thuộc tính"
                        : "Lưu thay đổi",
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

  /// Them du lieu moi vao danh sach hoac gio hang.
  void _addValue() {
    final value = _valueCtrl.text.trim();
    if (value.isEmpty) return;
    final exists = _values.any((item) => item.toLowerCase() == value.toLowerCase());
    if (!exists) {
      setState(() => _values.add(value));
    }
    _valueCtrl.clear();
  }

  /// Luu du lieu tu form hoac state hien tai.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.provider.saveAttribute(
        attribute: widget.attribute,
        name: _nameCtrl.text.trim(),
        values: _values,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.attribute == null
                  ? "Thêm thuộc tính thất bại: $e"
                  : "Cập nhật thuộc tính thất bại: $e",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _AttributeTile extends StatelessWidget {
  final AttributeModel attribute;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _AttributeTile({
    required this.attribute,
    required this.onEdit,
    required this.onDelete,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xffd1d5db)),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xffdbeafe),
          child: Icon(Icons.tune_outlined, color: Color(0xff2563eb)),
        ),
        title: Text(
          attribute.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (attribute.values.isEmpty)
                const Text("Chưa có giá trị")
              else
                ...attribute.values.map(
                  (value) => Chip(
                    label: Text(value),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == "edit") onEdit();
            if (value == "delete") onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: "edit", child: Text("Sửa")),
            PopupMenuItem(value: "delete", child: Text("Xóa")),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String subtitle;

  const _Header({required this.title, required this.subtitle});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_outlined, color: Color(0xff2563eb)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
