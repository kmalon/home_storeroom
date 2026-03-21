# Context
Plan 3: Make product names manageable as a dedicated screen (add/delete), like categories. Currently names are added inline inside AddProductScreen via a dialog. No deletion exists. Goal: decouple name management from product adding.

# Changes

## 1. Provider: add deleteProductName
- `lib/providers/storeroom_provider.dart`: add `deleteProductName(String name)`
  - Block if any product uses that name (throw Exception)
  - Filter name from list → `_save()`

## 2. New screen: ProductNamesScreen
- `lib/screens/product_names/product_names_screen.dart` — mirror `CategoriesScreen`:
  - TextField + Add button → calls `addProductName(name)` (already exists)
  - ListView of names with delete IconButton → calls `deleteProductName(name)`
  - Delete disabled if any product uses that name (show usage count as subtitle)
  - Empty state text

## 3. Routing: add /product-names to ShellRoute
- `lib/app.dart`: add `GoRoute(path: '/product-names', builder: ProductNamesScreen)` inside ShellRoute routes
- Import new screen

## 4. HomeScreen: add 3rd tab
- `lib/screens/home/home_screen.dart`:
  - `_routes` → add `'/product-names'`
  - `NavigationBar` destinations → add `NavigationDestination(icon: Icons.label_outline, label: l.namesTab)`

## 5. AddProductScreen: remove inline name adding
- `lib/screens/add_product/add_product_screen.dart`:
  - Remove `_addNewName()` method
  - Remove `IconButton` (add_circle_outline) next to name dropdown
  - Remove `addNewName` tooltip usage

## 6. Localizations
- `lib/l10n/app_localizations.dart`: add
  - `namesTab` — 'Names' / 'Nazwy'
  - `newProductNameField` — 'New product name' / 'Nowa nazwa produktu' (reuse existing `newProductName`)
  - `noNamesYet` — 'No product names yet' / 'Brak nazw produktów'
  - `deleteProductName` — 'Delete name' / 'Usuń nazwę'
  - `cannotDeleteNameProducts` — 'Cannot delete: products exist' / 'Nie można usunąć: istnieją produkty'

# Files to modify
- `lib/providers/storeroom_provider.dart` — add deleteProductName
- `lib/screens/product_names/product_names_screen.dart` — new file
- `lib/app.dart` — add route
- `lib/screens/home/home_screen.dart` — 3rd tab
- `lib/screens/add_product/add_product_screen.dart` — remove inline add
- `lib/l10n/app_localizations.dart` — new strings

# Reuse
- `CategoriesScreen` pattern (add/delete/disable-when-in-use)
- `addProductName()` in `StoreroomNotifier` (already exists)

# Verification
1. Open app → 3rd tab "Names" visible in bottom nav
2. Add a name → appears in list
3. Delete unused name → removed from list and from add/edit dropdowns
4. Try to delete name used by a product → delete button disabled
5. Add product → name dropdown has no inline add button
6. Edit product → name dropdown populated from managed list

# Branch
`feature/manage-product-names`
