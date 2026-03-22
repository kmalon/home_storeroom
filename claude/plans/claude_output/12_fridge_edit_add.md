# Output: 12_fridge_edit_add

## Changes Made

### 1. `lib/providers/storeroom_provider.dart`
- Added `updateFridgeProduct(FridgeProduct updated)` — finds by id, replaces in list, saves
- Added `addFridgeProduct(FridgeProduct product)` — appends to fridgeProducts, saves

### 2. `lib/screens/fridge/fridge_screen.dart`
- Added `_showEditSheet()` — bottom sheet with name dropdown, qty, expiry date fields
- Added edit icon button per row → opens edit sheet
- Widened header SizedBox from 40→80 to accommodate 2 icon buttons
- Added `go_router` import (removed after moving FAB to HomeScreen)

### 3. `lib/screens/fridge/add_fridge_product_screen.dart` (new)
- 3-step stepper: Category → Barcode → Details (name, qty, expiry)
- Uses `categoryExpiryDays` for default expiry date suggestion
- On submit: calls `addFridgeProduct()` with `insertionDate = DateTime.now()`

### 4. `lib/app.dart`
- Added import for `AddFridgeProductScreen`
- Added route `/add-fridge-product` → `AddFridgeProductScreen`

### 5. `lib/screens/home/home_screen.dart`
- Added FAB for fridge tab (selectedIndex == 1) → navigates to `/add-fridge-product`

### 6. `lib/l10n/app_localizations.dart`
- Added `editFridgeProduct` (EN/PL)
- Added `addFridgeProduct` (EN/PL)

## Verification
- `flutter analyze`: No issues found

## Branch
`feature/12-fridge-edit-add`
