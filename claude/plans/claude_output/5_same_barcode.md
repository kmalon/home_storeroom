# Plan: 5_same_barcode.md — Execution Output

## Branch
`feature/reject-duplicate-barcode`

## Changes Made

### 1. `lib/providers/storeroom_provider.dart`
- Replaced increment-quantity logic with `throw Exception('Barcode already exists')` in `addProduct` when a duplicate barcode is detected.

### 2. `lib/l10n/app_localizations.dart`
- Added `barcodeAlreadyExistsTitle` (en/pl)
- Added `barcodeAlreadyExistsBody` (en/pl)
- Added `ok` (en/pl)

### 3. `lib/screens/add_product/add_product_screen.dart`
- In `_submit()`, catch block now detects `'Barcode already exists'` exception and shows `AlertDialog` popup instead of a snackbar.
