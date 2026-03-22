# Output: 8_expirity_date_warning

## Changes Made

### `lib/models/storeroom_data.dart`
- Added `expiryWarningDays` field (default 7) to StoreroomData
- Updated `copyWith` to support `expiryWarningDays`

### `lib/services/excel_service.dart`
- Added `_configSheet = 'config'` constant
- `parse()`: reads config sheet, extracts `expiryWarningDays` (fallback: 7)
- `encode()`: writes config sheet with key=`expiryWarningDays`, value=N

### `lib/providers/storeroom_provider.dart`
- Added `updateExpiryWarningDays(int days)` method

### `lib/l10n/app_localizations.dart`
- Added `configTab`, `expiryWarningDaysLabel`, `configSaved` strings (EN/PL)

### `lib/screens/config/config_screen.dart` (NEW)
- Number field for `expiryWarningDays` + Save button
- On save: calls provider → triggers Drive upload

### `lib/screens/home/home_screen.dart`
- Added 4th NavigationBar item: Config (settings icon)
- Added `/config` to routes list

### `lib/app.dart`
- Imported ConfigScreen
- Added `/config` GoRoute inside ShellRoute

### `lib/screens/product_list/product_list_screen.dart`
- Row highlighting updated:
  - Red: expired/today (existing)
  - Orange: expiring within `expiryWarningDays` days (new)

## Result
`flutter analyze` → No issues found
