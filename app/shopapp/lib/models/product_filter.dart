class ProductFilter {
  List<String> brands;
  List<String> colors;
  List<String> sizes;
  double? minPrice;
  double? maxPrice;

  ProductFilter({
    this.brands = const [],
    this.colors = const [],
    this.sizes = const [],
    this.minPrice,
    this.maxPrice,
  });

  static ProductFilter from(ProductFilter other) => ProductFilter(
  brands: List.from(other.brands),
  colors: List.from(other.colors),
  sizes: List.from(other.sizes),
  minPrice: other.minPrice,
  maxPrice: other.maxPrice,
);
}