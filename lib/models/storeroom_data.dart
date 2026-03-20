import 'product.dart';
import 'category.dart';

class StoreroomData {
  final List<Product> products;
  final List<Category> categories;
  final List<String> productNames;

  const StoreroomData({
    required this.products,
    required this.categories,
    required this.productNames,
  });

  StoreroomData copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<String>? productNames,
  }) {
    return StoreroomData(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      productNames: productNames ?? this.productNames,
    );
  }

  static StoreroomData empty() =>
      const StoreroomData(products: [], categories: [], productNames: []);
}
