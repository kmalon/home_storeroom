# Plan Output: Feature 10 — Search by Category or Name

**Branch:** feature/10-find-by-category-name

## Changes Made

### `lib/l10n/app_localizations.dart`
- Added `searchHint` string (EN/PL)

### `lib/screens/product_list/product_list_screen.dart`
- Added `_searchController` TextEditingController
- Disposed `_searchController` in `dispose()`
- Updated `_hasActiveFilters` to include search query
- Updated `_clearFilters()` to clear search
- Updated `_applyFilters()` to filter by search text (category or name, case-insensitive substring)
- Added search TextField to UI above the filter panel
