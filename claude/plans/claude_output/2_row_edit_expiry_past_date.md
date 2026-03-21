# Context
Plan 2: Add inline row editing to product list + allow past expiry dates.
Currently: rows only react to long-press (remove). No edit flow exists. Date picker blocks past dates via `firstDate: DateTime.now()`.

# Changes

## 1. Allow past expiry dates
- `lib/screens/add_product/add_product_screen.dart` line 53: change `firstDate: DateTime.now()` → `firstDate: DateTime(2000)`
- Same fix in new edit dialog (below)

## 2. Row tap → edit bottom sheet/dialog
- `lib/screens/product_list/product_list_screen.dart`: add `onTap` to InkWell → show `showModalBottomSheet` with edit form
- Edit form fields: name (TextField), quantity (int TextField), expiry date (date picker, firstDate: DateTime(2000))
- Pre-populate with tapped product's current values

## 3. Provider: add updateProduct
- `lib/providers/storeroom_provider.dart`: add `updateProduct(Product updated)` method
  - Find product by id in list → replace with updated → re-encode & upload to Drive (same pattern as addProduct)

## 4. ExcelService: already supports encode/decode — no changes needed

# Files to modify
- `lib/screens/add_product/add_product_screen.dart` — fix firstDate
- `lib/screens/product_list/product_list_screen.dart` — onTap + edit modal widget
- `lib/providers/storeroom_provider.dart` — updateProduct method

# Verification
1. Run app → product list → tap a row → bottom sheet opens with current values
2. Change expiry to a past date → confirm save works, list shows red highlight
3. Change name/qty → confirm Excel updated on Drive
4. Add new product with past expiry date → confirm allowed

# Branch
`feature/row-edit-past-expiry`

# Unresolved questions
- None
