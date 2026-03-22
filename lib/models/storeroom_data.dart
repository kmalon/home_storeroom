import 'product.dart';
import 'category.dart';
import 'product_name.dart';
import 'fridge_product.dart';

class StoreroomData {
  final List<Product> products;
  final List<Category> categories;
  final List<ProductName> productNames;
  final int expiryWarningDays;
  final List<FridgeProduct> fridgeProducts;
  final Map<String, int> categoryExpiryDays;

  const StoreroomData({
    required this.products,
    required this.categories,
    required this.productNames,
    this.expiryWarningDays = 7,
    this.fridgeProducts = const [],
    this.categoryExpiryDays = const {},
  });

  StoreroomData copyWith({
    List<Product>? products,
    List<Category>? categories,
    List<ProductName>? productNames,
    int? expiryWarningDays,
    List<FridgeProduct>? fridgeProducts,
    Map<String, int>? categoryExpiryDays,
  }) {
    return StoreroomData(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      productNames: productNames ?? this.productNames,
      expiryWarningDays: expiryWarningDays ?? this.expiryWarningDays,
      fridgeProducts: fridgeProducts ?? this.fridgeProducts,
      categoryExpiryDays: categoryExpiryDays ?? this.categoryExpiryDays,
    );
  }

  static StoreroomData empty() =>
      const StoreroomData(products: [], categories: [], productNames: []);
}
