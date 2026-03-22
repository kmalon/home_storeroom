import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../providers/storeroom_provider.dart';
import '../../widgets/sort_header.dart';
import '../../widgets/loading_overlay.dart';

enum _SortField { category, name, barcode, quantity, expiration }

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  // Sort
  _SortField _sortField = _SortField.name;
  bool _sortAsc = true;
  bool _loading = false;

  // Filters
  bool _showFilters = false;
  final Set<String> _filterCategories = {};
  final Set<String> _filterNames = {};
  final _minQtyController = TextEditingController();
  final _maxQtyController = TextEditingController();
  DateTime? _minExpiry;
  DateTime? _maxExpiry;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _minQtyController.dispose();
    _maxQtyController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilters =>
      _filterCategories.isNotEmpty ||
      _filterNames.isNotEmpty ||
      _minQtyController.text.isNotEmpty ||
      _maxQtyController.text.isNotEmpty ||
      _minExpiry != null ||
      _maxExpiry != null;

  void _clearFilters() {
    setState(() {
      _filterCategories.clear();
      _filterNames.clear();
      _minQtyController.clear();
      _maxQtyController.clear();
      _minExpiry = null;
      _maxExpiry = null;
    });
  }

  void _toggleSort(_SortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  List<Product> _applyFilters(List<Product> products) {
    final minQty = int.tryParse(_minQtyController.text);
    final maxQty = int.tryParse(_maxQtyController.text);
    return products.where((p) {
      if (_filterCategories.isNotEmpty && !_filterCategories.contains(p.category)) return false;
      if (_filterNames.isNotEmpty && !_filterNames.contains(p.name)) return false;
      if (minQty != null && p.quantity < minQty) return false;
      if (maxQty != null && p.quantity > maxQty) return false;
      if (_minExpiry != null) {
        final d = DateTime(p.expirationDate.year, p.expirationDate.month, p.expirationDate.day);
        if (d.isBefore(_minExpiry!)) return false;
      }
      if (_maxExpiry != null) {
        final d = DateTime(p.expirationDate.year, p.expirationDate.month, p.expirationDate.day);
        if (d.isAfter(_maxExpiry!)) return false;
      }
      return true;
    }).toList();
  }

  List<Product> _sorted(List<Product> products) {
    final sorted = List.of(products);
    sorted.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case _SortField.category:
          cmp = a.category.compareTo(b.category);
        case _SortField.name:
          cmp = a.name.compareTo(b.name);
        case _SortField.barcode:
          cmp = a.barcode.compareTo(b.barcode);
        case _SortField.quantity:
          cmp = a.quantity.compareTo(b.quantity);
        case _SortField.expiration:
          cmp = a.expirationDate.compareTo(b.expirationDate);
      }
      return _sortAsc ? cmp : -cmp;
    });
    return sorted;
  }

  Future<void> _showEditSheet(BuildContext context, Product product) async {
    final l = AppLocalizations.of(context);
    final allProductNames = ref.read(storeroomProvider).valueOrNull?.productNames ?? [];
    final productNames = allProductNames
        .where((n) => n.category == product.category)
        .map((n) => n.name)
        .toList();
    final qtyController = TextEditingController(text: '${product.quantity}');
    DateTime? expiry = product.expirationDate;
    String? selectedName = productNames.contains(product.name) ? product.name : null;

    ref.read(editSheetOpenProvider.notifier).state = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.editProduct,
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l.productNameField,
                      border: const OutlineInputBorder(),
                    ),
                    value: selectedName,
                    items: productNames
                        .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                        .toList(),
                    onChanged: (v) => setSheetState(() => selectedName = v),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      labelText: l.quantityField,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: expiry ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setSheetState(() => expiry = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l.expirationDateField,
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        expiry != null
                            ? _dateFmt.format(expiry!)
                            : l.tapToSelect,
                        style: TextStyle(
                          color: expiry != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(l.cancel),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = selectedName;
                          final qty = int.tryParse(qtyController.text) ?? product.quantity;
                          if (name == null || name.isEmpty || expiry == null) return;
                          Navigator.of(ctx).pop();
                          setState(() => _loading = true);
                          try {
                            await ref.read(storeroomProvider.notifier).updateProduct(
                                  product.copyWith(
                                    name: name,
                                    quantity: qty,
                                    expirationDate: expiry!,
                                  ),
                                );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l.errorMessage(e))),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _loading = false);
                          }
                        },
                        child: Text(l.save),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    ref.read(editSheetOpenProvider.notifier).state = false;
    qtyController.dispose();
  }

  Future<void> _pickDate(bool isMin) async {
    final initial = isMin
        ? (_minExpiry ?? DateTime.now())
        : (_maxExpiry ?? DateTime.now().add(const Duration(days: 365)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isMin) _minExpiry = picked;
        else _maxExpiry = picked;
      });
    }
  }

  Widget _buildChipGroup({
    required String label,
    required List<String> options,
    required Set<String> selected,
    required String allLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            FilterChip(
              label: Text(allLabel),
              selected: selected.isEmpty,
              onSelected: (_) => setState(() => selected.clear()),
            ),
            ...options.map((o) => FilterChip(
                  label: Text(o),
                  selected: selected.contains(o),
                  onSelected: (v) => setState(() {
                    if (v) selected.add(o);
                    else selected.remove(o);
                  }),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterPanel(AppLocalizations l, List<String> categories, List<String> names) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChipGroup(
            label: l.colCategory,
            options: categories,
            selected: _filterCategories,
            allLabel: l.allCategories,
          ),
          const SizedBox(height: 10),
          _buildChipGroup(
            label: l.colName,
            options: names,
            selected: _filterNames,
            allLabel: l.allNames,
          ),
          const SizedBox(height: 10),
          // Qty range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minQtyController,
                  decoration: InputDecoration(
                    labelText: l.qtyMin,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _maxQtyController,
                  decoration: InputDecoration(
                    labelText: l.qtyMax,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Expiry range
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(true),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.expiryFrom,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(
                      _minExpiry != null ? _dateFmt.format(_minExpiry!) : l.any,
                      style: TextStyle(color: _minExpiry != null ? null : Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(false),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l.expiryTo,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(
                      _maxExpiry != null ? _dateFmt.format(_maxExpiry!) : l.any,
                      style: TextStyle(color: _maxExpiry != null ? null : Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                label: Text(l.clearAllFilters),
                onPressed: _clearFilters,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(storeroomProvider);
    return LoadingOverlay(
      isLoading: _loading,
      child: state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l.errorMessage(e))),
      data: (data) {
        final categories = data.categories.map((c) => c.name).toList();
        final names = data.productNames.map((n) => n.name).toSet().toList();
        final products = _sorted(_applyFilters(data.products));

        if (data.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l.noProductsYet, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text(l.addProduct),
                  onPressed: () => context.push('/add-product'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Filter toggle bar
            InkWell(
              onTap: () => setState(() => _showFilters = !_showFilters),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _showFilters ? Icons.filter_list_off : Icons.filter_list,
                      size: 18,
                      color: _hasActiveFilters
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _showFilters ? l.hideFilters : l.filters,
                      style: TextStyle(
                        fontSize: 13,
                        color: _hasActiveFilters
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        fontWeight:
                            _hasActiveFilters ? FontWeight.bold : null,
                      ),
                    ),
                    if (_hasActiveFilters) ...[
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _clearFilters,
                        child: const Icon(Icons.cancel, size: 16, color: Colors.grey),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${products.length} / ${data.products.length}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            if (_showFilters) _buildFilterPanel(l, categories, names),
            const Divider(height: 1),
            // Sort headers
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SortHeader(
                      label: l.colCategory,
                      isActive: _sortField == _SortField.category,
                      ascending: _sortAsc,
                      onTap: () => _toggleSort(_SortField.category),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SortHeader(
                      label: l.colName,
                      isActive: _sortField == _SortField.name,
                      ascending: _sortAsc,
                      onTap: () => _toggleSort(_SortField.name),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SortHeader(
                      label: l.colBarcode,
                      isActive: _sortField == _SortField.barcode,
                      ascending: _sortAsc,
                      onTap: () => _toggleSort(_SortField.barcode),
                    ),
                  ),
                  Expanded(
                    child: SortHeader(
                      label: l.colQty,
                      isActive: _sortField == _SortField.quantity,
                      ascending: _sortAsc,
                      onTap: () => _toggleSort(_SortField.quantity),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SortHeader(
                      label: l.colExpiry,
                      isActive: _sortField == _SortField.expiration,
                      ascending: _sortAsc,
                      onTap: () => _toggleSort(_SortField.expiration),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: products.isEmpty
                  ? Center(
                      child: Text(l.noProductsMatchFilters,
                          style: const TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = products[index];
                        final expiry = _dateFmt.format(p.expirationDate);
                        final today = DateTime.now();
                        final expiryDate = DateTime(p.expirationDate.year,
                            p.expirationDate.month, p.expirationDate.day);
                        final todayDate =
                            DateTime(today.year, today.month, today.day);
                        final warningDays = ref
                            .watch(storeroomProvider)
                            .valueOrNull
                            ?.expiryWarningDays ?? 7;
                        final warningDate = todayDate.add(Duration(days: warningDays));
                        final isExpiredOrToday = !expiryDate.isAfter(todayDate);
                        final isExpiringSoon = !isExpiredOrToday && expiryDate.isBefore(warningDate);
                        Color? rowColor;
                        if (isExpiredOrToday) {
                          rowColor = Colors.red.shade50;
                        } else if (isExpiringSoon) {
                          rowColor = Colors.orange.shade50;
                        }
                        return InkWell(
                          onTap: () => _showEditSheet(context, p),
                          onLongPress: () => context.push('/remove-product'),
                          child: Container(
                            color: rowColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(p.category,
                                        style: const TextStyle(fontSize: 13))),
                                Expanded(flex: 2, child: Text(p.name)),
                                Expanded(flex: 2, child: Text(p.barcode, style: const TextStyle(fontSize: 11))),
                                Expanded(child: Text('${p.quantity}')),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    expiry,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isExpiredOrToday
                                          ? Colors.red
                                          : isExpiringSoon
                                              ? Colors.orange.shade800
                                              : null,
                                      fontWeight: (isExpiredOrToday || isExpiringSoon)
                                          ? FontWeight.bold
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                icon: const Icon(Icons.remove_circle_outline),
                label: Text(l.removeProduct),
                onPressed: () => context.push('/remove-product'),
              ),
            ),
          ],
        );
      },
    ));
  }
}
