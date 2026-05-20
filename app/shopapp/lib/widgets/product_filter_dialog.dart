import 'package:flutter/material.dart';

import '../features/user/product/models/product_browse_args.dart';
import '../models/category.dart';

class ProductFilterDialog extends StatefulWidget {
  final ProductBrowseArgs initialArgs;
  final List<Category> categories;
  final Future<List<String>> brandsFuture;
  final String storageKey;

  const ProductFilterDialog({
    super.key,
    required this.initialArgs,
    required this.categories,
    required this.brandsFuture,
    this.storageKey = "product_filter_dialog_list",
  });

  /// Tao state quan ly vong doi cua widget.
  @override
  State<ProductFilterDialog> createState() => _ProductFilterDialogState();
}

class _ProductFilterDialogState extends State<ProductFilterDialog> {
  late final ScrollController _scrollController;
  late final Set<int> _selectedCategoryIds;
  late final Set<String> _selectedCategoryNames;
  late final Set<String> _selectedBrands;
  late double? _selectedRating;
  late RangeValues _priceRange;

  List<Category> get _filterCategories {
    return widget.categories.where((category) {
      final name = category.name.trim().toLowerCase();
      return category.id != 0 && name != "tat ca";
    }).toList();
  }

  /// Khoi tao state va du lieu ban dau cho man hinh.
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _selectedCategoryIds = {
      ...?widget.initialArgs.categoryIds,
      if (widget.initialArgs.categoryId != null &&
          widget.initialArgs.categoryId != 0)
        widget.initialArgs.categoryId!,
    };
    _selectedCategoryNames = {
      for (final category in _filterCategories)
        if (_selectedCategoryIds.contains(category.id)) category.name,
    };
    _selectedBrands = {
      ...?widget.initialArgs.brands,
      if (widget.initialArgs.brand != null &&
          widget.initialArgs.brand!.isNotEmpty)
        widget.initialArgs.brand!,
    };
    _selectedRating = widget.initialArgs.minRating;
    _priceRange = RangeValues(
      (widget.initialArgs.minPrice ?? 0).clamp(0, 1000000).toDouble(),
      (widget.initialArgs.maxPrice ?? 1000000).clamp(0, 1000000).toDouble(),
    );
  }

  /// Giai phong controller, listener va tai nguyen khi widget bi huy.
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Xu ly logic cho ham _reset.
  void _reset() {
    setState(() {
      _selectedCategoryIds.clear();
      _selectedCategoryNames.clear();
      _selectedBrands.clear();
      _selectedRating = null;
      _priceRange = const RangeValues(0, 1000000);
    });
  }

  /// Xu ly logic cho ham _submit.
  void _submit() {
    Navigator.pop(
      context,
      widget.initialArgs.copyWith(
        categoryIds:
            _selectedCategoryIds.isEmpty ? null : _selectedCategoryIds.toList(),
        brands: _selectedBrands.isEmpty ? null : _selectedBrands.toList(),
        minRating: _selectedRating,
        minPrice: _priceRange.start <= 0 ? null : _priceRange.start,
        maxPrice: _priceRange.end >= 1000000 ? null : _priceRange.end,
        title: filterTitle(
          selectedCategoryNames: _selectedCategoryNames.toList(),
          selectedBrands: _selectedBrands.toList(),
        ),
        clearCategoryId: true,
        clearCategoryIds: _selectedCategoryIds.isEmpty,
        clearBrand: true,
        clearBrands: _selectedBrands.isEmpty,
        clearMinRating: _selectedRating == null,
        clearMinPrice: _priceRange.start <= 0,
        clearMaxPrice: _priceRange.end >= 1000000,
      ),
    );
  }

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 720),
        child: Column(
          children: [
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffe5e7eb))),
              ),
              child: Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        "Bộ lọc",
                        style: TextStyle(
                          color: Color(0xff111827),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _reset,
                    child: const Text(
                      "Đặt lại",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                key: PageStorageKey(widget.storageKey),
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  _FilterSection(
                    title: "Khoảng giá",
                    child: Column(
                      children: [
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 1000000,
                          divisions: 10,
                          activeColor: const Color(0xff2563eb),
                          inactiveColor: const Color(0xffbfdbfe),
                          onChanged: (value) {
                            setState(() => _priceRange = value);
                          },
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _priceBox(
                                label: "Giá thấp nhất",
                                value: _formatVnd(_priceRange.start),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _priceBox(
                                label: "Giá cao nhất",
                                value: _formatVnd(_priceRange.end),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _FilterSection(
                    title: "Đánh giá",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) {
                        final rating = (index + 1).toDouble();
                        final selected =
                            _selectedRating != null &&
                            rating <= _selectedRating!;
                        return IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            setState(() {
                              _selectedRating =
                                  _selectedRating == rating ? null : rating;
                            });
                          },
                          icon: Icon(
                            Icons.star_rounded,
                            color:
                                selected
                                    ? const Color(0xffff8a00)
                                    : const Color(0xffc7c9e8),
                            size: 32,
                          ),
                        );
                      }),
                    ),
                  ),
                  _FilterSection(
                    title: "Danh mục",
                    child: Column(
                      children: [
                        _filterCheckRow(
                          label: "Tất cả",
                          selected: _selectedCategoryIds.isEmpty,
                          onTap: () {
                            setState(() {
                              _selectedCategoryIds.clear();
                              _selectedCategoryNames.clear();
                            });
                          },
                        ),
                        ..._filterCategories.map((category) {
                          return _filterCheckRow(
                            label: category.name,
                            selected: _selectedCategoryIds.contains(
                              category.id,
                            ),
                            onTap: () {
                              setState(() {
                                if (_selectedCategoryIds.contains(
                                  category.id,
                                )) {
                                  _selectedCategoryIds.remove(category.id);
                                  _selectedCategoryNames.remove(category.name);
                                } else {
                                  _selectedCategoryIds.add(category.id);
                                  _selectedCategoryNames.add(category.name);
                                }
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                  FutureBuilder<List<String>>(
                    future: widget.brandsFuture,
                    builder: (context, snapshot) {
                      final brands = snapshot.data ?? [];
                      return _FilterSection(
                        title: "Thương hiệu",
                        child:
                            snapshot.connectionState == ConnectionState.waiting
                                ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                : Column(
                                  children: [
                                    _filterCheckRow(
                                      label: "Tất cả",
                                      selected: _selectedBrands.isEmpty,
                                      onTap: () {
                                        setState(_selectedBrands.clear);
                                      },
                                    ),
                                    ...brands.map((brand) {
                                      return _filterCheckRow(
                                        label: brand,
                                        selected: _selectedBrands.contains(
                                          brand,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (_selectedBrands.contains(
                                              brand,
                                            )) {
                                              _selectedBrands.remove(brand);
                                            } else {
                                              _selectedBrands.add(brand);
                                            }
                                          });
                                        },
                                      );
                                    }),
                                  ],
                                ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xffe5e7eb))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2563eb),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text(
                    "Lọc",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String filterTitle({
    required List<String> selectedCategoryNames,
    required List<String> selectedBrands,
  }) {
    final parts = [
      if (selectedCategoryNames.isNotEmpty) selectedCategoryNames.join(", "),
      if (selectedBrands.isNotEmpty) selectedBrands.join(", "),
    ];

    return parts.isEmpty ? "Sản phẩm" : parts.join(" - ");
  }

  /// Xu ly logic cho ham _priceBox.
  Widget _priceBox({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe5e7eb)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xffc4c8d4), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xff1f2937),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  /// Xu ly logic cho ham _filterCheckRow.
  Widget _filterCheckRow({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 34,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffedf0f5))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff1f2937),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              activeColor: const Color(0xff2563eb),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Xu ly logic cho ham _formatVnd.
  static String _formatVnd(double value) {
    final rounded = value.round();
    if (rounded >= 1000000) {
      final million = rounded / 1000000;
      final fixed = million == million.roundToDouble() ? 0 : 1;
      return "${million.toStringAsFixed(fixed)}M VND";
    }
    return "${(rounded / 1000).round()}k VND";
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  /// Xay dung giao dien hien thi cho widget.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xff1f2937),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
