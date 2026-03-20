# Home Storeroom Flutter App

## Context
Flutter app (Android + iOS) to track storeroom inventory. Uses Google Drive Excel file as shared DB — multiple users on same Google account see live shared state. Built from scratch in `/home/km/dev/workdir/ai/home_storeroom/`.

## Key Decisions
- Conflict: last upload wins (no merge)
- Same barcode added again: increment quantity (merge rows)
- Expiration date: required
- Category delete: blocked if products exist
- State mgmt: Riverpod
- Navigation: go_router

## Excel Schema (`storeroom.xlsx`)
Sheet `products` (row 1 = headers):
| id (uuid) | category | barcode | name | quantity | expiration_date (yyyy-MM-dd) |

Sheet `categories` (row 1 = header):
| name |

## GCP OAuth Setup (one-time, include in README)
Explain to user:
- Google requires every app using their APIs to register in Google Cloud Console
- Having Gmail is NOT enough for programmatic API access
- Steps: Create project → Enable Drive API → Create OAuth 2.0 Client IDs (one for Android with SHA-1, one for iOS with bundle ID) → download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- No billing required for Drive API at this usage level

## Project Structure
```
home_storeroom/
  pubspec.yaml
  android/app/src/main/AndroidManifest.xml   (camera + internet perms)
  ios/Runner/Info.plist                       (camera usage, URL scheme)
  lib/
    main.dart
    app.dart                    # ProviderScope + GoRouter + auth redirect guard
    models/
      product.dart              # Freezed: id, category, barcode, name, quantity, expirationDate
      category.dart             # Freezed: name
      storeroom_data.dart       # Plain class: List<Product>, List<Category>
    services/
      auth_service.dart         # GoogleSignIn singleton, scopes: email + driveFileScope
      drive_service.dart        # findOrCreateFile, downloadFile, uploadFile
      excel_service.dart        # parse(Uint8List)->StoreRoomData, encode(StoreRoomData)->Uint8List
    providers/
      auth_provider.dart        # StreamProvider<GoogleSignInAccount?> from signIn onChange
      storeroom_provider.dart   # AsyncNotifier<StoreRoomData> — all business logic
    screens/
      login/login_screen.dart
      home/home_screen.dart             # BottomNav: Product List + Categories
      categories/categories_screen.dart
      product_list/product_list_screen.dart
      add_product/
        add_product_screen.dart         # Stepper: category→barcode→details
        barcode_scan_screen.dart        # Full-screen MobileScanner, returns barcode string
      remove_product/remove_product_screen.dart  # TabBar: Scan | Manual
    widgets/
      sort_header.dart          # Tappable column header with sort arrow
      product_tile.dart
      loading_overlay.dart
  README.md                     # GCP setup instructions
```

## Dependencies (`pubspec.yaml`)
```yaml
google_sign_in: ^6.2.1
googleapis: ^13.2.0
googleapis_auth: ^1.6.0
http: ^1.2.0
excel: ^4.0.2
mobile_scanner: ^5.1.0
flutter_riverpod: ^2.5.1
riverpod_annotation: ^2.3.5
go_router: ^13.2.0
intl: ^0.19.0
uuid: ^4.4.0
freezed_annotation: ^2.4.1
dev: build_runner, riverpod_generator, freezed, json_serializable
```

## Key Logic

### drive_service.dart
1. Build `AuthClient` from `googleSignIn.authenticatedClient()`
2. Query Drive for folder `name='home_storeroom'`; create if absent
3. Query for `name='storeroom.xlsx'` inside that folder; create empty xlsx if absent
4. `downloadFile(fileId) -> Uint8List`
5. `uploadFile(fileId, bytes)` via `Media` stream update

### storeroom_provider.dart (AsyncNotifier)
- `build()`: findOrCreate → download → parse
- `_save(data)`: encode → upload → state = data
- `addProduct(p)`:
  - find existing row with same barcode
  - if found: increment quantity (ignore new expiry)
  - if not: append new row
  - `_save`
- `removeProduct(barcode, qty)`:
  - find row; if row.qty <= qty: delete row; else decrement
  - `_save`
- `addCategory(name)`: append to categories sheet, `_save`
- `deleteCategory(name)`: if any product.category == name → throw error; else remove, `_save`

### add_product_screen.dart (Stepper, 3 steps)
1. DropdownButton of categories
2. Scan button (push barcode_scan_screen, await result) OR manual TextField
3. name TextField, quantity number field, DatePicker for expiry (required)
→ Confirm → `addProduct` → pop

### remove_product_screen.dart (TabBar)
- **Scan tab**: MobileScanner → barcode shown → qty field → Confirm → `removeProduct`
- **Manual tab**: category dropdown → product name dropdown (filtered) → qty → Confirm → `removeProduct`

### product_list_screen.dart
- `DataTable` or `ListView` with `sort_header` widgets
- Local sort state: `sortField` enum + `sortAsc` bool
- Client-side sort on `StoreRoomData.products`
- Columns: category, name, barcode, qty, expiration date

## Verification
1. `flutter pub get` — no dep conflicts
2. `flutter analyze` — no errors
3. Android: `flutter run` on emulator/device — sign in, Drive folder created, add product, verify xlsx in Drive
4. iOS: same on Simulator
5. Two devices same account: add product on one, force-refresh on other → same data

## Unresolved Questions
None.
