import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  final Locale locale;
  const AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  bool get _isPl => locale.languageCode == 'pl';
  String _t(String en, String pl) => _isPl ? pl : en;

  // App
  String get appTitle => _t('Home Storeroom', 'Spiżarnia');

  // Login
  String get signInSubtitle => _t(
        'Sign in to sync inventory via Google Drive',
        'Zaloguj się, aby synchronizować spiżarnię przez Google Drive',
      );
  String get signInButton => _t('Sign in with Google', 'Zaloguj przez Google');
  String signInFailed(Object e) =>
      _t('Sign in failed: $e', 'Logowanie nie powiodło się: $e');

  // Home
  String get refresh => _t('Refresh', 'Odśwież');
  String get signOut => _t('Sign out', 'Wyloguj');

  // Bottom nav
  String get productsTab => _t('Products', 'Produkty');
  String get categoriesTab => _t('Categories', 'Kategorie');
  String get namesTab => _t('Names', 'Nazwy');
  String get configTab => _t('Config', 'Ustawienia');

  // Config screen
  String get expiryWarningDaysLabel => _t('Expiry warning (days)', 'Ostrzeżenie o ważności (dni)');
  String get configSaved => _t('Settings saved', 'Ustawienia zapisane');

  // Product list
  String get noProductsYet => _t('No products yet', 'Brak produktów');
  String get addProduct => _t('Add Product', 'Dodaj produkt');
  String get removeProduct => _t('Remove Product', 'Usuń produkt');
  String get filters => _t('Filters', 'Filtry');
  String get hideFilters => _t('Hide filters', 'Ukryj filtry');
  String get clearAllFilters => _t('Clear all filters', 'Wyczyść filtry');
  String get qtyMin => _t('Qty min', 'Ilość min');
  String get qtyMax => _t('Qty max', 'Ilość maks');
  String get expiryFrom => _t('Expiry from', 'Ważność od');
  String get expiryTo => _t('Expiry to', 'Ważność do');
  String get noProductsMatchFilters =>
      _t('No products match the filters', 'Brak produktów spełniających kryteria');
  String get any => _t('Any', 'Dowolna');
  String get allCategories => _t('All categories', 'Wszystkie kategorie');
  String get allNames => _t('All names', 'Wszystkie nazwy');

  // Column headers
  String get colCategory => _t('Category', 'Kategoria');
  String get colName => _t('Name', 'Nazwa');
  String get colQty => _t('Qty', 'Ilość');
  String get colExpiry => _t('Expiry', 'Ważność');
  String get colBarcode => _t('Barcode', 'Kod kreskowy');

  // Categories screen
  String get newCategory => _t('New category', 'Nowa kategoria');
  String get add => _t('Add', 'Dodaj');
  String get noCategoriesYet => _t('No categories yet', 'Brak kategorii');
  String get cannotDeleteTitle => _t('Cannot Delete', 'Nie można usunąć');
  String cannotDeleteCategoryBody(int n) => _t(
        '$n product(s) use this category.',
        '$n produkt(ów) używa tej kategorii.',
      );
  String get deleteCategory => _t('Delete category', 'Usuń kategorię');
  String productCount(int n) => _t('$n product(s)', '$n produkt(ów)');

  // Product names screen
  String get newProductNameField => _t('New product name', 'Nowa nazwa produktu');
  String get noNamesYet => _t('No product names yet', 'Brak nazw produktów');
  String get deleteProductName => _t('Delete name', 'Usuń nazwę');
  String cannotDeleteNameBody(int n) => _t(
        '$n product(s) use this name.',
        '$n produkt(ów) używa tej nazwy.',
      );

  // Add product
  String get selectCategory => _t('Select a category', 'Wybierz kategorię');
  String get noCategoriesHint => _t(
        'No categories. Add one in the Categories tab first.',
        'Brak kategorii. Najpierw dodaj kategorię w zakładce Kategorie.',
      );
  String get barcodeOptional => _t('Barcode (optional)', 'Kod kreskowy (opcjonalnie)');
  String get scan => _t('Scan', 'Skanuj');
  String get productNameField => _t('Product name *', 'Nazwa produktu *');
  String get quantityField => _t('Quantity *', 'Ilość *');
  String get expirationDateField => _t('Expiration date *', 'Data ważności *');
  String get tapToSelect => _t('Tap to select', 'Dotknij, aby wybrać');
  String get fillRequiredFields =>
      _t('Please fill all required fields', 'Wypełnij wszystkie wymagane pola');
  String get newProductName => _t('New product name', 'Nowa nazwa produktu');
  String get name => _t('Name', 'Nazwa');
  String get cancel => _t('Cancel', 'Anuluj');
  String get addNewName => _t('Add new name', 'Dodaj nową nazwę');
  String errorMessage(Object e) => _t('Error: $e', 'Błąd: $e');

  // Stepper steps
  String get stepCategory => _t('Category', 'Kategoria');
  String get stepBarcode => _t('Barcode', 'Kod kreskowy');
  String get stepDetails => _t('Details', 'Szczegóły');

  // Barcode scan
  String get scanBarcode => _t('Scan Barcode', 'Skanuj kod kreskowy');

  // Remove product
  String get scanTab => _t('Scan', 'Skanuj');
  String get manualTab => _t('Manual', 'Ręcznie');
  String get productNotFound =>
      _t('Product not found in inventory.', 'Produkt nie znaleziony w spiżarni.');
  String get quantityToRemove => _t('Quantity to remove', 'Ilość do usunięcia');
  String get confirm => _t('Confirm', 'Potwierdź');
  String get rescan => _t('Re-scan', 'Skanuj ponownie');
  String productInfo(String productName, int qty) =>
      _t('Product: $productName (qty: $qty)', 'Produkt: $productName (ilość: $qty)');
  String get barcodeLabel => _t('Barcode: ', 'Kod: ');
  String get barcodeAlreadyExistsTitle => _t('Barcode Already Exists', 'Kod kreskowy już istnieje');
  String get barcodeAlreadyExistsBody => _t(
        'A product with this barcode is already in the storeroom.',
        'Produkt z tym kodem kreskowym już istnieje w spiżarni.',
      );
  String get ok => _t('OK', 'OK');
  String get product => _t('Product', 'Produkt');
  String get addCategoryTitle => _t('Add Category', 'Dodaj kategorię');
  String get addNameTitle => _t('Add Name', 'Dodaj nazwę');
  String get categoryAlreadyExists => _t('Category already exists', 'Kategoria już istnieje');
  String get nameAlreadyExists => _t('Name already exists', 'Nazwa już istnieje');
  String get selectCategoryForName => _t('Select category for name', 'Wybierz kategorię dla nazwy');

  // Edit product
  String get editProduct => _t('Edit Product', 'Edytuj produkt');
  String get save => _t('Save', 'Zapisz');

  // Language picker
  String get language => _t('Language', 'Język');
  String get systemDefault => _t('System default', 'Domyślny systemu');
  String get english => 'English';
  String get polish => 'Polski';

  static const delegate = _AppLocalizationsDelegate();

  static const localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const supportedLocales = [
    Locale('en'),
    Locale('pl'),
  ];
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_) => false;
}
