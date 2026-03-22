import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/storeroom_data.dart';

class ExcelService {
  static const _productsSheet = 'products';
  static const _categoriesSheet = 'categories';
  static const _namesSheet = 'product_names';
  static const _configSheet = 'config';
  static final _dateFormat = DateFormat('yyyy-MM-dd');

  StoreroomData parse(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);

    final products = <Product>[];
    final categories = <Category>[];
    final productNames = <String>[];

    // Parse categories
    final catSheet = excel[_categoriesSheet];
    for (var i = 1; i < catSheet.rows.length; i++) {
      final row = catSheet.rows[i];
      final name = _cellString(row, 0);
      if (name.isNotEmpty) {
        categories.add(Category(name: name));
      }
    }

    // Parse product names
    if (excel.tables.containsKey(_namesSheet)) {
      final namesSheet = excel[_namesSheet];
      for (var i = 1; i < namesSheet.rows.length; i++) {
        final name = _cellString(namesSheet.rows[i], 0);
        if (name.isNotEmpty) productNames.add(name);
      }
    }

    // Parse products
    final prodSheet = excel[_productsSheet];
    for (var i = 1; i < prodSheet.rows.length; i++) {
      final row = prodSheet.rows[i];
      final id = _cellString(row, 0);
      final category = _cellString(row, 1);
      final barcode = _cellString(row, 2);
      final name = _cellString(row, 3);
      final quantityStr = _cellString(row, 4);
      final expiryStr = _cellString(row, 5);

      if (id.isEmpty && barcode.isEmpty && name.isEmpty) continue;

      final quantity = int.tryParse(quantityStr) ?? 0;
      DateTime? expiry;
      try {
        expiry = _dateFormat.parse(expiryStr);
      } catch (_) {
        expiry = DateTime(2099);
      }

      products.add(Product(
        id: id.isNotEmpty ? id : const Uuid().v4(),
        category: category,
        barcode: barcode,
        name: name,
        quantity: quantity,
        expirationDate: expiry,
      ));
    }

    int expiryWarningDays = 7;
    if (excel.tables.containsKey(_configSheet)) {
      final configSheet = excel[_configSheet];
      for (var i = 1; i < configSheet.rows.length; i++) {
        final row = configSheet.rows[i];
        final key = _cellString(row, 0);
        final value = _cellString(row, 1);
        if (key == 'expiryWarningDays') {
          expiryWarningDays = int.tryParse(value) ?? 7;
        }
      }
    }

    return StoreroomData(
      products: products,
      categories: categories,
      productNames: productNames,
      expiryWarningDays: expiryWarningDays,
    );
  }

  Uint8List encode(StoreroomData data) {
    final excel = Excel.createExcel();

    // Remove default sheet
    excel.delete('Sheet1');

    // Categories sheet
    final catSheet = excel[_categoriesSheet];
    catSheet.appendRow([TextCellValue('name')]);
    for (final cat in data.categories) {
      catSheet.appendRow([TextCellValue(cat.name)]);
    }

    // Product names sheet
    final namesSheet = excel[_namesSheet];
    namesSheet.appendRow([TextCellValue('name')]);
    for (final name in data.productNames) {
      namesSheet.appendRow([TextCellValue(name)]);
    }

    // Products sheet
    final prodSheet = excel[_productsSheet];
    prodSheet.appendRow([
      TextCellValue('id'),
      TextCellValue('category'),
      TextCellValue('barcode'),
      TextCellValue('name'),
      TextCellValue('quantity'),
      TextCellValue('expiration_date'),
    ]);
    for (final p in data.products) {
      prodSheet.appendRow([
        TextCellValue(p.id),
        TextCellValue(p.category),
        TextCellValue(p.barcode),
        TextCellValue(p.name),
        IntCellValue(p.quantity),
        TextCellValue(_dateFormat.format(p.expirationDate)),
      ]);
    }

    // Config sheet
    final configSheet = excel[_configSheet];
    configSheet.appendRow([TextCellValue('key'), TextCellValue('value')]);
    configSheet.appendRow([
      TextCellValue('expiryWarningDays'),
      IntCellValue(data.expiryWarningDays),
    ]);

    final encoded = excel.encode();
    if (encoded == null) throw Exception('Failed to encode Excel');
    return Uint8List.fromList(encoded);
  }

  String _cellString(List<Data?> row, int index) {
    if (index >= row.length) return '';
    final cell = row[index];
    if (cell == null) return '';
    return cell.value?.toString() ?? '';
  }
}
