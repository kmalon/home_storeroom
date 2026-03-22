import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/storeroom_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  static const _routes = ['/products', '/fridge', '/categories', '/product-names', '/config'];

  Future<void> _pickLanguage(AppLocalizations l) async {
    final current = ref.read(localeProvider);
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.language),
        children: [
          _langOption(ctx, null, l.systemDefault, current),
          _langOption(ctx, 'en', l.english, current),
          _langOption(ctx, 'pl', l.polish, current),
        ],
      ),
    );
    if (picked == 'system') {
      ref.read(localeProvider.notifier).state = null;
    } else if (picked != null) {
      ref.read(localeProvider.notifier).state = Locale(picked);
    }
  }

  Widget _langOption(BuildContext ctx, String? code, String label, Locale? current) {
    final isSelected = code == null
        ? current == null
        : current?.languageCode == code;
    return SimpleDialogOption(
      onPressed: () => Navigator.of(ctx).pop(code ?? 'system'),
      child: Row(
        children: [
          Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _pickLanguage(l),
            tooltip: l.language,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(storeroomProvider.notifier).refresh(),
            tooltip: l.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
            tooltip: l.signOut,
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
          context.go(_routes[index]);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.list_alt), label: l.productsTab),
          NavigationDestination(icon: const Icon(Icons.kitchen), label: l.fridgeTab),
          NavigationDestination(icon: const Icon(Icons.category), label: l.categoriesTab),
          NavigationDestination(icon: const Icon(Icons.label_outline), label: l.namesTab),
          NavigationDestination(icon: const Icon(Icons.settings), label: l.configTab),
        ],
      ),
      floatingActionButton: _selectedIndex == 0 && !ref.watch(editSheetOpenProvider)
          ? FloatingActionButton(
              onPressed: () => context.push('/add-product'),
              child: const Icon(Icons.add),
            )
          : _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => context.push('/add-fridge-product'),
              tooltip: AppLocalizations.of(context).addFridgeProduct,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
