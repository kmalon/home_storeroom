# Plan: 14_fridge_expiry_date

## Context
When moving product storeroom→fridge, expiry date in fridge should default to `min(storeroom_expiry, now + config_days)`. Currently this logic exists BUT storeroom `expirationDate` is non-nullable, so "not set" case is unhandled. Plan: make it nullable, allow products without expiry, handle null throughout.

## Changes

### 1. `lib/models/product.dart`
`required DateTime expirationDate` → `DateTime? expirationDate`
Then run: `flutter pub run build_runner build --delete-conflicting-outputs`
(regenerates `product.freezed.dart`, `product.g.dart`)

### 2. `lib/services/excel_service.dart`
- **Read** (line 57): `expiry = DateTime(2099)` → `expiry = null`
- **Write** (line 205): `_dateFormat.format(p.expirationDate)` → `p.expirationDate != null ? _dateFormat.format(p.expirationDate!) : ''`

### 3. `lib/screens/add_product/add_product_screen.dart`
- **Validation** (line 188): remove `expiry == null` from required-fields check
- **Constructor** (line 206): `expirationDate: expiry` stays (expiry is `DateTime?`, now matches)

### 4. `lib/widgets/product_tile.dart`
- Line 11: guard null → show `'—'` if no expiry
- Line 12: guard null → skip `isExpired` check if null

### 5. `lib/screens/product_list/product_list_screen.dart`
- **Sort** (line 117): null expiry sorts last (`null` treated as `DateTime(9999,...)`)
- **Filter** (lines 92, 96): null expiry = no date constraint → not matched by date filter (exclude from date-filtered results or treat as "no expiry")
- **Edit sheet** (line 133): `DateTime? expiry = product.expirationDate;` stays (already nullable)
- **Edit sheet display** (line 187): show `'—'` if null; allow clearing expiry
- **Update product** (line 230): `expirationDate: expiry` (remove `!`, pass nullable)
- **Display** (lines 651, 653-654): guard null
- **Move-to-fridge** (lines 263-265): update logic:
  ```dart
  final storeroomExpiry = product.expirationDate;
  final suggested = storeroomExpiry != null && storeroomExpiry.isBefore(defaultExpiry)
      ? storeroomExpiry
      : defaultExpiry;
  ```

## Verification
1. Add product without expiry date → should save successfully
2. Add product with expiry date → works as before
3. Move product (no expiry) to fridge → dialog pre-fills with `now + config_days`
4. Move product (expiry before config default) → dialog pre-fills with storeroom expiry
5. Move product (expiry after config default) → dialog pre-fills with config default
6. Fridge list shows correct expiry

## No questions

## Branch
`feature/14-fridge-expiry-date`
