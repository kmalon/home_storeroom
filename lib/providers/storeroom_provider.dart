import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/product_name.dart';
import '../models/fridge_product.dart';
import '../models/storeroom_data.dart';
import '../services/drive_service.dart';
import '../services/excel_service.dart';

class StoreroomNotifier extends AsyncNotifier<StoreroomData> {
  final _drive = DriveService();
  final _excel = ExcelService();
  String? _fileId;

  @override
  Future<StoreroomData> build() async {
    final (fileId, isNew) = await _drive.findOrCreateFile();
    _fileId = fileId;
    if (isNew) return StoreroomData.empty();
    final bytes = await _drive.downloadFile(fileId);
    if (bytes.isEmpty) return StoreroomData.empty();
    return _excel.parse(bytes);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final (fileId, _) = await _drive.findOrCreateFile();
      _fileId = fileId;
      final bytes = await _drive.downloadFile(fileId);
      if (bytes.isEmpty) return StoreroomData.empty();
      return _excel.parse(bytes);
    });
  }

  Future<void> _save(StoreroomData data) async {
    final bytes = _excel.encode(data);
    await _drive.uploadFile(_fileId!, bytes);
    state = AsyncData(data);
  }

  Future<void> addProduct(Product product) async {
    final current = state.requireValue;
    final existing = current.products.indexWhere(
      (p) => p.barcode == product.barcode,
    );

    if (existing >= 0) {
      throw Exception('Barcode already exists');
    }
    final updated = [...current.products, product];

    await _save(current.copyWith(products: updated));
  }

  Future<void> removeProduct(String barcode, int qty) async {
    final current = state.requireValue;
    final index = current.products.indexWhere((p) => p.barcode == barcode);
    if (index < 0) throw Exception('Product not found');

    List<Product> updated = List.of(current.products);
    final existing = updated[index];
    if (existing.quantity <= qty) {
      updated.removeAt(index);
    } else {
      updated[index] = existing.copyWith(quantity: existing.quantity - qty);
    }

    await _save(current.copyWith(products: updated));
  }

  Future<void> updateProduct(Product updated) async {
    final current = state.requireValue;
    final index = current.products.indexWhere((p) => p.id == updated.id);
    if (index < 0) throw Exception('Product not found');
    final products = List.of(current.products);
    products[index] = updated;
    await _save(current.copyWith(products: products));
  }

  Future<void> addCategory(String name) async {
    final current = state.requireValue;
    if (current.categories.any((c) => c.name == name)) {
      throw Exception('Category already exists');
    }
    final updatedCategories = [...current.categories, Category(name: name)];
    final updatedExpiryDays = Map<String, int>.from(current.categoryExpiryDays);
    updatedExpiryDays.putIfAbsent(name, () => 7);
    await _save(current.copyWith(
      categories: updatedCategories,
      categoryExpiryDays: updatedExpiryDays,
    ));
  }

  Future<void> addProductName(String name, String category) async {
    final current = state.requireValue;
    if (current.productNames.any((n) => n.name == name && n.category == category)) {
      throw Exception('Product name already exists');
    }
    await _save(current.copyWith(
      productNames: [...current.productNames, ProductName(name: name, category: category)],
    ));
  }

  Future<void> deleteProductName(ProductName pn) async {
    final current = state.requireValue;
    if (current.products.any((p) => p.name == pn.name && p.category == pn.category)) {
      throw Exception('Cannot delete name: products exist');
    }
    if (current.fridgeProducts.any((p) => p.name == pn.name && p.category == pn.category)) {
      throw Exception('Cannot delete name: products exist');
    }
    final updated = current.productNames
        .where((n) => !(n.name == pn.name && n.category == pn.category))
        .toList();
    await _save(current.copyWith(productNames: updated));
  }

  Future<void> deleteCategory(String name) async {
    final current = state.requireValue;
    if (current.products.any((p) => p.category == name)) {
      throw Exception('Cannot delete category: products exist');
    }
    if (current.fridgeProducts.any((p) => p.category == name)) {
      throw Exception('Cannot delete category: products exist');
    }
    final updatedCategories = current.categories.where((c) => c.name != name).toList();
    final updatedNames = current.productNames.where((n) => n.category != name).toList();
    final updatedExpiryDays = Map<String, int>.from(current.categoryExpiryDays)..remove(name);
    await _save(current.copyWith(
      categories: updatedCategories,
      productNames: updatedNames,
      categoryExpiryDays: updatedExpiryDays,
    ));
  }

  Future<void> updateExpiryWarningDays(int days) async {
    final current = state.requireValue;
    await _save(current.copyWith(expiryWarningDays: days));
  }

  Future<void> updateCategoryExpiryDays(String category, int days) async {
    final current = state.requireValue;
    final updated = Map<String, int>.from(current.categoryExpiryDays);
    updated[category] = days;
    await _save(current.copyWith(categoryExpiryDays: updated));
  }

  Future<void> moveToFridge(String productId, DateTime expiryDate) async {
    final current = state.requireValue;
    final index = current.products.indexWhere((p) => p.id == productId);
    if (index < 0) throw Exception('Product not found');

    final product = current.products[index];
    final fridgeProduct = FridgeProduct(
      id: const Uuid().v4(),
      category: product.category,
      name: product.name,
      barcode: product.barcode,
      quantity: product.quantity,
      insertionDate: DateTime.now(),
      expiryDate: expiryDate,
    );

    final updatedProducts = List.of(current.products)..removeAt(index);
    final updatedFridge = [...current.fridgeProducts, fridgeProduct];

    await _save(current.copyWith(
      products: updatedProducts,
      fridgeProducts: updatedFridge,
    ));
  }

  Future<void> removeFridgeProduct(String id, int qty) async {
    final current = state.requireValue;
    final index = current.fridgeProducts.indexWhere((p) => p.id == id);
    if (index < 0) throw Exception('Fridge product not found');

    final updated = List.of(current.fridgeProducts);
    final existing = updated[index];
    if (existing.quantity <= qty) {
      updated.removeAt(index);
    } else {
      updated[index] = existing.copyWith(quantity: existing.quantity - qty);
    }

    await _save(current.copyWith(fridgeProducts: updated));
  }
}

final storeroomProvider =
    AsyncNotifierProvider<StoreroomNotifier, StoreroomData>(
  StoreroomNotifier.new,
);

final editSheetOpenProvider = StateProvider<bool>((ref) => false);
