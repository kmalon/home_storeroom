import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/storeroom_provider.dart';
import '../../widgets/loading_overlay.dart';

class ConfigScreen extends ConsumerStatefulWidget {
  const ConfigScreen({super.key});

  @override
  ConsumerState<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends ConsumerState<ConfigScreen> {
  late TextEditingController _warningDaysController;
  final Map<String, TextEditingController> _categoryControllers = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _warningDaysController = TextEditingController();
  }

  @override
  void dispose() {
    _warningDaysController.dispose();
    for (final c in _categoryControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncCategoryControllers(Map<String, int> categoryExpiryDays) {
    for (final entry in categoryExpiryDays.entries) {
      if (!_categoryControllers.containsKey(entry.key)) {
        _categoryControllers[entry.key] =
            TextEditingController(text: '${entry.value}');
      }
    }
    final toRemove = _categoryControllers.keys
        .where((k) => !categoryExpiryDays.containsKey(k))
        .toList();
    for (final k in toRemove) {
      _categoryControllers[k]!.dispose();
      _categoryControllers.remove(k);
    }
  }

  Future<void> _saveWarningDays(AppLocalizations l) async {
    final days = int.tryParse(_warningDaysController.text);
    if (days == null || days < 0) return;
    setState(() => _saving = true);
    try {
      await ref.read(storeroomProvider.notifier).updateExpiryWarningDays(days);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.configSaved)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveCategoryExpiry(String category, AppLocalizations l) async {
    final controller = _categoryControllers[category];
    if (controller == null) return;
    final days = int.tryParse(controller.text);
    if (days == null || days < 0) return;
    setState(() => _saving = true);
    try {
      await ref.read(storeroomProvider.notifier).updateCategoryExpiryDays(category, days);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.configSaved)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final data = ref.watch(storeroomProvider);

    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(l.errorMessage(e))),
      data: (storeroom) {
        if (_warningDaysController.text.isEmpty) {
          _warningDaysController.text = storeroom.expiryWarningDays.toString();
        }
        _syncCategoryControllers(storeroom.categoryExpiryDays);

        return LoadingOverlay(
          isLoading: _saving,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _warningDaysController,
                  decoration: InputDecoration(
                    labelText: l.expiryWarningDaysLabel,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _saving ? null : () => _saveWarningDays(l),
                    child: Text(l.save),
                  ),
                ),
                if (storeroom.categoryExpiryDays.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    l.categoryExpiryDaysLabel,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  ...storeroom.categoryExpiryDays.entries.map((entry) {
                    final controller = _categoryControllers[entry.key];
                    if (controller == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              decoration: InputDecoration(
                                labelText: entry.key,
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _saving ? null : () => _saveCategoryExpiry(entry.key, l),
                            child: Text(l.save),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
