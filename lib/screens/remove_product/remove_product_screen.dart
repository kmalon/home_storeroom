import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/storeroom_provider.dart';
import '../../widgets/loading_overlay.dart';

class RemoveProductScreen extends ConsumerStatefulWidget {
  const RemoveProductScreen({super.key});

  @override
  ConsumerState<RemoveProductScreen> createState() =>
      _RemoveProductScreenState();
}

class _RemoveProductScreenState extends ConsumerState<RemoveProductScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _scanController = MobileScannerController();
  String? _scannedBarcode;
  final _scanQtyController = TextEditingController(text: '1');
  bool _scanLoading = false;

  String? _selectedCategory;
  String? _selectedBarcode;
  final _manualQtyController = TextEditingController(text: '1');
  bool _manualLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scanController.dispose();
    _scanQtyController.dispose();
    _manualQtyController.dispose();
    super.dispose();
  }

  Future<void> _confirmScan(AppLocalizations l) async {
    final barcode = _scannedBarcode;
    if (barcode == null) return;
    final qty = int.tryParse(_scanQtyController.text) ?? 1;
    setState(() => _scanLoading = true);
    try {
      await ref.read(storeroomProvider.notifier).removeProduct(barcode, qty);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _scanLoading = false);
    }
  }

  Future<void> _confirmManual(AppLocalizations l) async {
    final barcode = _selectedBarcode;
    if (barcode == null) return;
    final qty = int.tryParse(_manualQtyController.text) ?? 1;
    setState(() => _manualLoading = true);
    try {
      await ref.read(storeroomProvider.notifier).removeProduct(barcode, qty);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.errorMessage(e))));
      }
    } finally {
      if (mounted) setState(() => _manualLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(storeroomProvider);
    final data = state.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.removeProduct),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: l.scanTab), Tab(text: l.manualTab)],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Scan tab
          LoadingOverlay(
            isLoading: _scanLoading,
            child: _scannedBarcode == null
                ? MobileScanner(
                    controller: _scanController,
                    onDetect: (capture) {
                      final barcode = capture.barcodes.firstOrNull?.rawValue;
                      if (barcode != null) {
                        setState(() => _scannedBarcode = barcode);
                        _scanController.stop();
                      }
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${l.barcodeLabel}$_scannedBarcode',
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        if (data != null) ...[
                          () {
                            final product = data.products
                                .where((p) => p.barcode == _scannedBarcode)
                                .firstOrNull;
                            if (product == null) {
                              return Text(l.productNotFound,
                                  style: const TextStyle(color: Colors.red));
                            }
                            return Text(l.productInfo(product.name, product.quantity));
                          }(),
                        ],
                        const SizedBox(height: 16),
                        TextField(
                          controller: _scanQtyController,
                          decoration: InputDecoration(
                            labelText: l.quantityToRemove,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _confirmScan(l),
                                child: Text(l.confirm),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _scannedBarcode = null),
                              child: Text(l.rescan),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),

          // Manual tab
          LoadingOverlay(
            isLoading: _manualLoading,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: data == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: l.colCategory,
                            border: const OutlineInputBorder(),
                          ),
                          value: _selectedCategory,
                          items: data.categories
                              .map((c) => DropdownMenuItem(
                                  value: c.name, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedCategory = v;
                            _selectedBarcode = null;
                          }),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: l.product,
                            border: const OutlineInputBorder(),
                          ),
                          value: _selectedBarcode,
                          items: data.products
                              .where((p) =>
                                  _selectedCategory == null ||
                                  p.category == _selectedCategory)
                              .map((p) => DropdownMenuItem(
                                  value: p.barcode,
                                  child: Text(l.productInfo(p.name, p.quantity))))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedBarcode = v),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _manualQtyController,
                          decoration: InputDecoration(
                            labelText: l.quantityToRemove,
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _selectedBarcode != null
                                ? () => _confirmManual(l)
                                : null,
                            child: Text(l.confirm),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
