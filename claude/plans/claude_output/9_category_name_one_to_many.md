# Plan: 9 – Category→Name One-to-Many Relationship

## Context
Currently names (productNames) are a global `List<String>` with no link to categories. Plan requires:
- One category → many names; names unique per category (can duplicate across categories)
- Name add requires choosing a category
- Product add step 3 shows only names from selected category
- Delete name: only if no products reference that (category, name) pair
- Delete category: unchanged (no products with that category)

## Changes

### 1. New model: `lib/models/product_name.dart`
Freezed model: `{ required String name, required String category }`
Run `dart run build_runner build --delete-conflicting-outputs` after.

### 2. `lib/models/storeroom_data.dart`
- Change `List<String> productNames` → `List<ProductName> productNames`
- Update `copyWith`, `empty()`, import

### 3. `lib/services/excel_service.dart`
- **Parse** `product_names` sheet: add column 1 = `category`. If column missing/empty, auto-migrate: for each name find distinct categories in products; create one `ProductName(name, category)` per pair. If name unused in products, discard.
- **Encode** `product_names` sheet: header `['name', 'category']`, write both columns.

### 4. `lib/providers/storeroom_provider.dart`
- `addProductName(String name, String category)`: uniqueness check `productNames.any((n) => n.name == name && n.category == category)`
- `deleteProductName(ProductName pn)`: check `products.any((p) => p.name == pn.name && p.category == pn.category)`
- `deleteCategory(String name)`: unchanged logic; also delete all productNames for that category when deleting (or keep — keep simpler, names become orphaned). → **Delete associated names too** when category deleted.

### 5. `lib/screens/product_names/product_names_screen.dart`
Major rework:
- Add form: name TextField + category DropdownButton (all categories) + optional "+" to add new category inline + Add button
- List: each item shows name + subtitle with category + product count; delete validates per (name, category)
- State: add `String? _selectedCategory` for the add form

### 6. `lib/screens/add_product/add_product_screen.dart`
- Step 3: filter `productNames` by `_selectedCategory` → `data.productNames.where((n) => n.category == _selectedCategory).map((n) => n.name).toList()`
- `_showAddNameDialog`: no category selection needed (use `_selectedCategory`); call `addProductName(name, _selectedCategory!)`
- On category change in step 1: reset `_selectedName = null`

### 7. `lib/l10n/app_localizations.dart`
Add string: `selectCategoryForName` → `_t('Select category for name', 'Wybierz kategorię dla nazwy')`

## Files
- `lib/models/product_name.dart` (NEW)
- `lib/models/storeroom_data.dart`
- `lib/services/excel_service.dart`
- `lib/providers/storeroom_provider.dart`
- `lib/screens/product_names/product_names_screen.dart`
- `lib/screens/add_product/add_product_screen.dart`
- `lib/l10n/app_localizations.dart`

## Verification
1. Add category A, add name "Milk" to A → Milk appears only under A
2. Add category B, add name "Milk" to B → two separate entries
3. Add product: step 1 select A, step 3 shows only A's names
4. Delete name with products → blocked with count dialog
5. Delete category with associated names but no products → succeeds, names removed too
6. Old Excel (no category col in product_names) → auto-migrates from products data

## Questions
No questions.

## Branch
`feature/9-category-name-one-to-many`

---

## Fix: Add "Add New Category" Inline in ProductNamesScreen

### Issue
During adding a Name, user should be able to add a new Category if it doesn't exist — not only choose from dropdown. The original plan specified this ("optional '+' to add new category inline") but the implementation omitted it.

### Changes

#### `lib/screens/product_names/product_names_screen.dart`
- Added `_showAddCategoryDialog(AppLocalizations l)` method: dialog with category name input, calls `addCategory`, auto-selects new category on success
- Wrapped `DropdownButtonFormField` in a `Row` with `Expanded` + `IconButton(Icons.add)` that triggers the dialog

### Files Changed
- `lib/screens/product_names/product_names_screen.dart`

### Verification
1. Open Names screen → category row shows dropdown + "+" button
2. Tap "+" → dialog appears, enter new category name → category created and auto-selected in dropdown
3. Enter name text → tap Add → name added under new category
4. Existing dropdown still works for existing categories
