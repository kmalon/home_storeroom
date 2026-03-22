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
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _warningDaysController = TextEditingController();
  }

  @override
  void dispose() {
    _warningDaysController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l) async {
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
        return LoadingOverlay(
          isLoading: _saving,
          child: Padding(
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
                    onPressed: _saving ? null : () => _save(l),
                    child: Text(l.save),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
