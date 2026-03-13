import '../models/product.dart';

List<Product> mockProducts = List.generate(
  10,
  (index) => Product(
    id: index,
    name: "Áo thun thời trang $index",
    price: 100000,
    rating: 4.1,
    image: "https://picsum.photos/200?random=$index",
  ),
);