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
}