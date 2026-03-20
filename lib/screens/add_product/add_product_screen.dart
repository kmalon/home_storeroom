import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product.dart';
import '../../providers/storeroom_provider.dart';
import '../../widgets/loading_overlay.dart';
import 'barcode_scan_screen.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  int _step = 0;
  bool _loading = false;

  String? _selectedCategory;
  String? _selectedName;
  String _barcode = '';
  final _quantityController = TextEditingController(text: '1');
  final _barcodeController = TextEditingController();
  DateTime? _expirationDate;

  @override
  void dispose() {
    _quantityController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _scanBarcode() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScanScreen()),
    );
    if (result != null) {
      setState(() {
        _barcode = result;
        _barcodeController.text = result;
      });
    }
  }

  Future<void> _pickDate(AppLocalizations l) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _expirationDate = picked);
  }

  Future<void> _addNewName(AppLocalizations l) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.newProductName),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l.name,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l.add),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    try {
      await ref.read(storeroomProvider.notifier).addProductName(name);
      setState(() => _selectedName = name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorMessage(e))));
      }
    }
  }

  Future<void> _submit(AppLocalizations l) async {
    final category = _selectedCategory;
    final name = _selectedName;
    final qty = int.tryParse(_quantityController.text) ?? 1;
    final expiry = _expirationDate;

    if (category == null || name == null || name.isEmpty || expiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.fillRequiredFields)),
      );
      return;
    }

    final barcode = _barcode.isNotEmpty ? _barcode : _barcodeController.text.trim();

    setState(() => _loading = true);
    try {
      await ref.read(storeroomProvider.notifier).addProduct(
            Product(
              id: const Uuid().v4(),
              category: category,
              barcode: barcode.isNotEmpty ? barcode : const Uuid().v4(),
              name: name,
              quantity: qty,
              expirationDate: expiry,
            ),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(storeroomProvider);
    final categories = state.valueOrNull?.categories.map((c) => c.name).toList() ?? [];
    final productNames = state.valueOrNull?.productNames ?? [];

    return LoadingOverlay(
      isLoading: _loading,
      child: Scaffold(
        appBar: AppBar(title: Text(l.addProduct)),
        body: Stepper(
          currentStep: _step,
          onStepContinue: () {
            if (_step == 0 && _selectedCategory == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.selectCategory)),
              );
              return;
            }
            if (_step < 2) setState(() => _step++);
            else _submit(l);
          },
          onStepCancel: () {
            if (_step > 0) setState(() => _step--);
            else Navigator.of(context).pop();
          },
          steps: [
            Step(
              title: Text(l.stepCategory),
              isActive: _step >= 0,
              content: categories.isEmpty
                  ? Text(
                      l.noCategoriesHint,
                      style: const TextStyle(color: Colors.grey),
                    )
                  : DropdownButton<String>(
                      isExpanded: true,
                      hint: Text(l.selectCategory),
                      value: _selectedCategory,
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                    ),
            ),
            Step(
              title: Text(l.stepBarcode),
              isActive: _step >= 1,
              content: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _barcodeController,
                      decoration: InputDecoration(
                        labelText: l.barcodeOptional,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) => _barcode = v,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: Text(l.scan),
                    onPressed: _scanBarcode,
                  ),
                ],
              ),
            ),
            Step(
              title: Text(l.stepDetails),
              isActive: _step >= 2,
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: l.productNameField,
                            border: const OutlineInputBorder(),
                          ),
                          value: _selectedName,
                          items: productNames
                              .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedName = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: l.addNewName,
                        onPressed: () => _addNewName(l),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: l.quantityField,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _pickDate(l),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l.expirationDateField,
                        border: const OutlineInputBorder(),
                      ),
                      child: Text(
                        _expirationDate != null
                            ? DateFormat('yyyy-MM-dd').format(_expirationDate!)
                            : l.tapToSelect,
                        style: TextStyle(
                          color: _expirationDate != null ? null : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
