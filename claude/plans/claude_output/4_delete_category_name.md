# Plan 4: delete_category_name — Output Log

## Changes Made

### lib/l10n/app_localizations.dart
- Removed `cannotDeleteCategoryProducts` and `cannotDeleteNameProducts` getters
- Added `cannotDeleteTitle` getter ("Cannot Delete" / "Nie można usunąć")
- Added `cannotDeleteCategoryBody(int n)` method
- Added `cannotDeleteNameBody(int n)` method

### lib/screens/categories/categories_screen.dart
- Delete button always enabled (no more `onPressed: count > 0 ? null : ...`)
- When count > 0: shows `AlertDialog` with title + body explaining products exist
- When count == 0: proceeds with `_deleteCategory`

### lib/screens/product_names/product_names_screen.dart
- Same pattern as categories screen
- When count > 0: shows `AlertDialog` via `showDialog`
- When count == 0: proceeds with `_deleteName`
