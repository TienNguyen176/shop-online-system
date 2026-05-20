import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/category.dart';
import '../providers/category_provider.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  /// Tao state quan ly vong doi cua widget.
  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories(refresh: true);
    });
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xfff3f4f6),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openForm(provider),
            icon: const Icon(Icons.add),
            label: const Text("Thêm danh mục"),
          ),
          body: RefreshIndicator(
            onRefresh: () => provider.loadCategories(refresh: true),
            child:
                provider.isLoading && provider.flatCategories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                      children: [
                        _Header(
                          title: "Quản lý danh mục",
                          subtitle:
                              "${provider.flatCategories.length} danh mục",
                        ),
                        const SizedBox(height: 12),
                        if (provider.flatCategories.isEmpty)
                          const _EmptyState(message: "Chưa có danh mục")
                        else
                          ...provider.flatCategories.map(
                            (category) => _CategoryTile(
                              category: category,
                              parentName: _parentName(
                                provider.flatCategories,
                                category.parentId,
                              ),
                              onEdit: () => _openForm(provider, category),
                              onDelete: () => _confirmDelete(
                                provider,
                                category,
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

  /// Xu ly logic cho ham _parentName.
  String _parentName(List<Category> categories, int? parentId) {
    if (parentId == null) return "Danh mục gốc";
    for (final category in categories) {
      if (category.id == parentId) return category.name;
    }
    return "Không rõ";
  }

  /// Mo man hinh hoac hop thoai lien quan.
  Future<void> _openForm(
    CategoryProvider provider, [
    Category? category,
  ]) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CategoryFormSheet(
        provider: provider,
        category: category,
      ),
    );

    if (saved == true && mounted) {
      _showMessage(
        category == null
            ? "Thêm danh mục thành công"
            : "Cập nhật danh mục thành công",
      );
    }
  }

  /// Hien thi xac nhan truoc khi thuc hien hanh dong.
  Future<void> _confirmDelete(
    CategoryProvider provider,
    Category category,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xóa danh mục?"),
        content: Text("Bạn có chắc muốn xóa '${category.name}' không?"),
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
      await provider.deleteCategory(category.id);
      if (mounted) _showMessage("Xóa danh mục thành công");
    } catch (e) {
      if (mounted) _showMessage("Xóa danh mục thất bại: ${_friendlyError(e)}");
    }
  }

  /// Xu ly logic cho ham _friendlyError.
  String _friendlyError(Object e) {
    final text = e.toString();
    final marker = "message:";
    final index = text.indexOf(marker);
    if (index >= 0) return text.substring(index + marker.length).trim();
    return text;
  }

  /// Hien thi thong bao nhanh cho nguoi dung.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

class _CategoryFormSheet extends StatefulWidget {
  final CategoryProvider provider;
  final Category? category;

  const _CategoryFormSheet({
    required this.provider,
    this.category,
  });

  /// Tao state quan ly vong doi cua widget.
  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _slugCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  int? _parentId;
  bool _saving = false;

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    final category = widget.category;
    if (category != null) {
      _nameCtrl.text = category.name;
      _slugCtrl.text = category.slug;
      _imageCtrl.text = category.image ?? "";
      _parentId = category.parentId;
    }
  }

  /// Giai phong controller, listener va tai nguyen khi widget bi huy.
  @override
  void dispose() {
    _nameCtrl.dispose();
    _slugCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    final parents = widget.provider.flatCategories
        .where((item) => item.id != widget.category?.id)
        .toList();

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
                      widget.category == null
                          ? "Thêm danh mục"
                          : "Sửa danh mục",
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
                  labelText: "Tên danh mục",
                  border: OutlineInputBorder(),
                ),
                validator: _required,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _slugCtrl,
                decoration: const InputDecoration(
                  labelText: "Slug",
                  hintText: "Để trống để tự tạo",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _parentId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Danh mục cha",
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text("Danh mục gốc"),
                  ),
                  ...parents.map(
                    (category) => DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(
                        "${"  " * category.level}${category.name}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _parentId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: "Ảnh",
                  hintText: "URL hoặc đường dẫn ảnh",
                  border: OutlineInputBorder(),
                ),
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
                    widget.category == null ? "Thêm danh mục" : "Lưu thay đổi",
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

  /// Luu du lieu tu form hoac state hien tai.
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await widget.provider.saveCategory(
        category: widget.category,
        name: _nameCtrl.text.trim(),
        slug: _slugCtrl.text.trim(),
        parentId: _parentId,
        image: _imageCtrl.text.trim().isEmpty ? null : _imageCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.category == null
                  ? "Thêm danh mục thất bại: $e"
                  : "Cập nhật danh mục thất bại: $e",
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

class _CategoryTile extends StatelessWidget {
  final Category category;
  final String parentName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile({
    required this.category,
    required this.parentName,
    required this.onEdit,
    required this.onDelete,
  });

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xffdbeafe),
          child: Text(
            "${category.level + 1}",
            style: const TextStyle(
              color: Color(0xff2563eb),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text("Slug: ${category.slug}\nCha: $parentName"),
        isThreeLine: true,
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
          const Icon(Icons.category_outlined, color: Color(0xff2563eb)),
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
