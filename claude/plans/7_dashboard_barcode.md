As Flutter developer add features:
- barcode to the products list.
- loading spinner during user actions related to updating excel file.

## Branch
`feature/7-dashboard-barcode`

---

## Fix: Loading spinner in Add Category/Name dialogs (add product flow)

Issue: `_showAddCategoryDialog` and `_showAddNameDialog` in `add_product_screen.dart` had no loading feedback during async save operations.

Fix: Wrapped both dialogs with `StatefulBuilder`, added local `dialogLoading` bool. Add button shows `CircularProgressIndicator` (16x16, strokeWidth 2) while loading and is disabled. Cancel also disabled while loading.

File changed: `lib/screens/add_product/add_product_screen.dart`
