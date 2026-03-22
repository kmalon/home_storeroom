# Output: 7 - Dashboard Barcode & Loading Spinner

## Changes Made

### `lib/l10n/app_localizations.dart`
- Added `colBarcode` key: `'Barcode' / 'Kod kreskowy'`

### `lib/screens/product_list/product_list_screen.dart`
- Added `bool _loading = false` state
- Imported `LoadingOverlay`
- Added `SortHeader(colBarcode, flex:2)` between name and qty in headers row
- Added `Expanded(flex:2, child: Text(p.barcode, fontSize:11))` cell between name and qty in product rows
- In `_showEditSheet` save button: sets `_loading=true` after sheet closes, calls `updateProduct`, finally `_loading=false`
- Wrapped entire `build` return with `LoadingOverlay(isLoading: _loading, ...)`

### `lib/screens/categories/categories_screen.dart`
- Added `bool _loading = false` state
- Imported `LoadingOverlay`
- `_addCategory` & `_deleteCategory`: set `_loading=true/false` in try/finally
- Wrapped build Column with `LoadingOverlay`

### `lib/screens/product_names/product_names_screen.dart`
- Same pattern as categories screen
