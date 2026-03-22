import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_name.dart';
import '../../providers/storeroom_provider.dart';
import '../../widgets/loading_overlay.dart';

class ProductNamesScreen extends ConsumerStatefulWidget {
  const ProductNamesScreen({super.key});

  @override
  ConsumerState<ProductNamesScreen> createState() => _ProductNamesScreenState();
}

class _ProductNamesScreenState extends ConsumerState<ProductNamesScreen> {
  final _controller = TextEditingController();
  String? _selectedCategory;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog(AppLocalizations l) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        bool dialogLoading = false;
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            title: Text(l.addCategoryTitle),
            content: TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(hintText: l.newCategory),
            ),
            actions: [
              TextButton(
                onPressed: dialogLoading ? null : () => Navigator.of(ctx).pop(),
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: dialogLoading
                    ? null
                    : () async {
                        final name = controller.text.trim();
                        if (name.isEmpty) return;
                        setDialogState(() => dialogLoading = true);
                        try {
                          await ref.read(storeroomProvider.notifier).addCategory(name);
                          if (mounted) {
                            setState(() => _selectedCategory = name);
                            Navigator.of(ctx).pop();
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l.categoryAlreadyExists)),
                            );
                          }
                        } finally {
                          if (ctx.mounted) setDialogState(() => dialogLoading = false);
                        }
                      },
                child: dialogLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l.add),
              ),
            ],
          ),
        );
      },
    );
    controller.dispose();
  }

  Future<void> _addName(AppLocalizations l) async {
    final name = _controller.text.trim();
    final category = _selectedCategory;
    if (name.isEmpty || category == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(storeroomProvider.notifier).addProductName(name, category);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteName(ProductName pn) async {
    setState(() => _loading = true);
    try {
      await ref.read(storeroomProvider.notifier).deleteProductName(pn);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(storeroomProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l.errorMessage(e))),
      data: (data) {
        final categories = data.categories.map((c) => c.name).toList();
        return LoadingOverlay(
          isLoading: _loading,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: l.selectCategoryForName,
                              border: const OutlineInputBorder(),
                            ),
                            value: _selectedCategory,
                            items: categories
                                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                .toList(),
                            onChanged: (v) => setState(() => _selectedCategory = v),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: l.addCategoryTitle,
                          onPressed: () => _showAddCategoryDialog(l),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: l.newProductNameField,
                              border: const OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _addName(l),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _addName(l),
                          child: Text(l.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: data.productNames.isEmpty
                    ? Center(
                        child: Text(l.noNamesYet,
                            style: const TextStyle(color: Colors.grey)),
                      )
                    : ListView.separated(
                        itemCount: data.productNames.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final pn = data.productNames[index];
                          final count = data.products
                              .where((p) => p.name == pn.name && p.category == pn.category)
                              .length;
                          return ListTile(
                            title: Text(pn.name),
                            subtitle: Text('${pn.category} · ${l.productCount(count)}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: l.deleteProductName,
                              onPressed: () {
                                if (count > 0) {
                                  showDialog(
                                    context: context,
                                    builder: (dialogContext) => AlertDialog(
                                      title: Text(l.cannotDeleteTitle),
                                      content: Text(l.cannotDeleteNameBody(count)),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(dialogContext).pop(),
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  _deleteName(pn);
                                }
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
