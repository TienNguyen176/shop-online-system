class ProductBrowseArgs {
  final String? searchKeyword;
  final int? categoryId;
  final List<int>? categoryIds;
  final String? brand;
  final List<String>? brands;
  final double? minRating;
  final double? minPrice;
  final double? maxPrice;
  final String? title;

  const ProductBrowseArgs({
    this.searchKeyword,
    this.categoryId,
    this.categoryIds,
    this.brand,
    this.brands,
    this.minRating,
    this.minPrice,
    this.maxPrice,
    this.title,
  });

  ProductBrowseArgs copyWith({
    String? searchKeyword,
    int? categoryId,
    List<int>? categoryIds,
    String? brand,
    List<String>? brands,
    double? minRating,
    double? minPrice,
    double? maxPrice,
    String? title,
    bool clearSearchKeyword = false,
    bool clearCategoryId = false,
    bool clearCategoryIds = false,
    bool clearBrand = false,
    bool clearBrands = false,
    bool clearMinRating = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return ProductBrowseArgs(
      searchKeyword:
          clearSearchKeyword ? null : searchKeyword ?? this.searchKeyword,
      categoryId: clearCategoryId ? null : categoryId ?? this.categoryId,
      categoryIds: clearCategoryIds ? null : categoryIds ?? this.categoryIds,
      brand: clearBrand ? null : brand ?? this.brand,
      brands: clearBrands ? null : brands ?? this.brands,
      minRating: clearMinRating ? null : minRating ?? this.minRating,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      title: title ?? this.title,
    );
  }
}
