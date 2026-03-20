import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../models/category.dart';
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

    List<Product> updated;
    if (existing >= 0) {
      // Same barcode: increment quantity, keep original expiry
      updated = List.of(current.products);
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + product.quantity,
      );
    } else {
      updated = [...current.products, product];
    }

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

  Future<void> addCategory(String name) async {
    final current = state.requireValue;
    if (current.categories.any((c) => c.name == name)) {
      throw Exception('Category already exists');
    }
    final updated = [...current.categories, Category(name: name)];
    await _save(current.copyWith(categories: updated));
  }

  Future<void> addProductName(String name) async {
    final current = state.requireValue;
    if (current.productNames.contains(name)) {
      throw Exception('Product name already exists');
    }
    await _save(current.copyWith(productNames: [...current.productNames, name]));
  }

  Future<void> deleteCategory(String name) async {
    final current = state.requireValue;
    if (current.products.any((p) => p.category == name)) {
      throw Exception('Cannot delete category: products exist');
    }
    final updated = current.categories.where((c) => c.name != name).toList();
    await _save(current.copyWith(categories: updated));
  }
}

final storeroomProvider =
    AsyncNotifierProvider<StoreroomNotifier, StoreroomData>(
  StoreroomNotifier.new,
);
