import 'product.dart';
import 'category.dart';

class StoreroomData {
  final List<Product> products;
  final List<Category> categories;
  final List<String> productNames;
  final int expiryWarningDays;

  const StoreroomData({
    required this.products,
    required this.categories,
    required this.productNames,
    this.expiryWarningDays = 7,
  });

  StoreroomData copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<String>? productNames,
    int? expiryWarningDays,
  }) {
    return StoreroomData(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      productNames: productNames ?? this.productNames,
      expiryWarningDays: expiryWarningDays ?? this.expiryWarningDays,
    );
  }

  static StoreroomData empty() =>
      const StoreroomData(products: [], categories: [], productNames: []);
}
