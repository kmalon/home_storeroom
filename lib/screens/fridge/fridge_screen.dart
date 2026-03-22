import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../models/fridge_product.dart';
import '../../providers/storeroom_provider.dart';
import '../../widgets/loading_overlay.dart';

class FridgeScreen extends ConsumerStatefulWidget {
  const FridgeScreen({super.key});

  @override
  ConsumerState<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends ConsumerState<FridgeScreen> {
  bool _loading = false;
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  Future<void> _showRemoveDialog(BuildContext context, FridgeProduct product, AppLocalizations l) async {
    final qtyController = TextEditingController(text: '1');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.removeProduct),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${product.name} (${product.category})'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              decoration: InputDecoration(
                labelText: l.quantityToRemove,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    final qty = int.tryParse(qtyController.text) ?? 1;
    setState(() => _loading = true);
    try {
      await ref.read(storeroomProvider.notifier).removeFridgeProduct(product.id, qty);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.errorMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    qtyController.dispose();
  }

  Future<void> _showEditSheet(BuildContext context, FridgeProduct product, AppLocalizations l) async {
    final data = ref.read(storeroomProvider).valueOrNull;
    final allProductNames = data?.productNames ?? [];
    final productNames = allProductNames
        .where((n) => n.category == product.category)
        .map((n) => n.name)
        .toList();
    final qtyController = TextEditingController(text: '${product.quantity}');
    DateTime? expiry = product.expiryDate;
    String? selectedName = productNames.contains(product.name) ? product.name : null;

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
                  Text(l.editFridgeProduct,
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
                            await ref.read(storeroomProvider.notifier).updateFridgeProduct(
                                  product.copyWith(
                                    name: name,
                                    quantity: qty,
                                    expiryDate: expiry!,
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
    qtyController.dispose();
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
          if (data.fridgeProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.kitchen, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(l.noFridgeProducts, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final warningDays = data.expiryWarningDays;
          final today = DateTime.now();
          final todayDate = DateTime(today.year, today.month, today.day);

          return Column(
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(flex: 2, child: Text(l.colCategory, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text(l.colName, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    Expanded(child: Text(l.colQty, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text(l.insertionDate, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Text(l.colExpiry, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 80),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: data.fridgeProducts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final fp = data.fridgeProducts[index];
                    final expiryDate = DateTime(fp.expiryDate.year, fp.expiryDate.month, fp.expiryDate.day);
                    final warningDate = todayDate.add(Duration(days: warningDays));
                    final isExpired = !expiryDate.isAfter(todayDate);
                    final isExpiringSoon = !isExpired && expiryDate.isBefore(warningDate);

                    Color? rowColor;
                    if (isExpired) rowColor = Colors.red.shade50;
                    else if (isExpiringSoon) rowColor = Colors.orange.shade50;

                    return Container(
                      color: rowColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text(fp.category, style: const TextStyle(fontSize: 13))),
                          Expanded(flex: 2, child: Text(fp.name)),
                          Expanded(child: Text('${fp.quantity}')),
                          Expanded(flex: 2, child: Text(_dateFmt.format(fp.insertionDate), style: const TextStyle(fontSize: 12))),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _dateFmt.format(fp.expiryDate),
                              style: TextStyle(
                                fontSize: 12,
                                color: isExpired ? Colors.red : isExpiringSoon ? Colors.orange.shade800 : null,
                                fontWeight: (isExpired || isExpiringSoon) ? FontWeight.bold : null,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            onPressed: () => _showEditSheet(context, fp, l),
                            tooltip: l.editFridgeProduct,
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: () => _showRemoveDialog(context, fp, l),
                            tooltip: l.removeProduct,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
