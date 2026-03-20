import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/storeroom_provider.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addCategory(AppLocalizations l) async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    try {
      await ref.read(storeroomProvider.notifier).addCategory(name);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteCategory(String name) async {
    try {
      await ref.read(storeroomProvider.notifier).deleteCategory(name);
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
                        labelText: l.newCategory,
                        border: const OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addCategory(l),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addCategory(l),
                    child: Text(l.add),
                  ),
                ],
              ),
            ),
            Expanded(
              child: data.categories.isEmpty
                  ? Center(
                      child: Text(l.noCategoriesYet,
                          style: const TextStyle(color: Colors.grey)),
                    )
                  : ListView.separated(
                      itemCount: data.categories.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final cat = data.categories[index];
                        final count = data.products
                            .where((p) => p.category == cat.name)
                            .length;
                        return ListTile(
                          title: Text(cat.name),
                          subtitle: Text(l.productCount(count)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: count > 0
                                ? null
                                : () => _deleteCategory(cat.name),
                            tooltip: count > 0
                                ? l.cannotDeleteCategoryProducts
                                : l.deleteCategory,
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
