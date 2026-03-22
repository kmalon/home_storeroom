# Output: 6 - Add Category or Name from Add Product Flow

## Changes Made

### `lib/l10n/app_localizations.dart`
Added 4 new localization keys:
- `addCategoryTitle` — "Add Category" / "Dodaj kategorię"
- `addNameTitle` — "Add Name" / "Dodaj nazwę"
- `categoryAlreadyExists` — "Category already exists" / "Kategoria już istnieje"
- `nameAlreadyExists` — "Name already exists" / "Nazwa już istnieje"

### `lib/screens/add_product/add_product_screen.dart`
- Added `_showAddCategoryDialog()` method — shows AlertDialog with TextField, calls `addCategory()`, auto-selects new category, shows snackbar on duplicate
- Added `_showAddNameDialog()` method — shows AlertDialog with TextField, calls `addProductName()`, auto-selects new name, shows snackbar on duplicate
- Step 1 (Category): wrapped in Column; when categories exist, shows Row(dropdown + "+" IconButton); when empty, shows hint + TextButton.icon "Add Category"
- Step 3 (Name): wrapped DropdownButtonFormField in Row with "+" IconButton
