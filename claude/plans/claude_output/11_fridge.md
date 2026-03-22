# Plan Output: Feature 11 — Fridge Mode

## Changes Made

### New Files
- `lib/models/fridge_product.dart` — plain Dart class: id, category, name, barcode, quantity, insertionDate, expiryDate
- `lib/screens/fridge/fridge_screen.dart` — fridge product list with color-coded expiry, remove dialog

### Modified Files
- `lib/models/storeroom_data.dart` — added `fridgeProducts: List<FridgeProduct>`, `categoryExpiryDays: Map<String, int>`
- `lib/services/excel_service.dart` — added `fridge` sheet parse/encode; per-category expiry in config as `category_expiry_<name>` keys
- `lib/providers/storeroom_provider.dart` — added `moveToFridge`, `removeFridgeProduct`, `updateCategoryExpiryDays`; updated `addCategory` (adds default 7 days), `deleteCategory`/`deleteProductName` (check fridge too)
- `lib/app.dart` — added `/fridge` route
- `lib/screens/home/home_screen.dart` — added fridge tab (index 1, kitchen icon)
- `lib/screens/product_list/product_list_screen.dart` — "Move to Fridge" button in edit sheet with expiry dialog; expiry pre-calculated as min(storeroom date, today + category default days)
- `lib/screens/config/config_screen.dart` — per-category fridge expiry days section
- `lib/screens/categories/categories_screen.dart` — product count includes fridge products
- `lib/screens/product_names/product_names_screen.dart` — product count includes fridge products
- `lib/l10n/app_localizations.dart` — added: fridgeTab, moveToFridge, fridgeExpiryDate, insertionDate, noFridgeProducts, categoryExpiryDaysLabel, confirmMove
- `claude/plans/app_description.md` — updated to reflect dual-mode app

## Key Logic
Expiry calculation when moving to fridge:
```dart
final defaultDays = data.categoryExpiryDays[product.category] ?? 7;
final defaultExpiry = DateTime.now().add(Duration(days: defaultDays));
final suggested = product.expirationDate.isBefore(defaultExpiry)
    ? product.expirationDate
    : defaultExpiry;
```

## Analysis result
`dart analyze lib/` — No issues found.

## Branch
`feature/11-fridge`
