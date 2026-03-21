import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/storeroom_provider.dart';

class ProductNamesScreen extends ConsumerStatefulWidget {
  const ProductNamesScreen({super.key});

  @override
  ConsumerState<ProductNamesScreen> createState() => _ProductNamesScreenState();
}

class _ProductNamesScreenState extends ConsumerState<ProductNamesScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addName(AppLocalizations l) async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    try {
      await ref.read(storeroomProvider.notifier).addProductName(name);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteName(String name) async {
    try {
      await ref.read(storeroomProvider.notifier).deleteProductName(name);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                        final name = data.productNames[index];
                        final count = data.products
                            .where((p) => p.name == name)
                            .length;
                        return ListTile(
                          title: Text(name),
                          subtitle: Text(l.productCount(count)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l.deleteProductName,
                            onPressed: () {
                              if (count > 0) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(l.cannotDeleteTitle),
                                    content: Text(l.cannotDeleteNameBody(count)),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                _deleteName(name);
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
