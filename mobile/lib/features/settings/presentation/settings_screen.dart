import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/network/api_exception.dart';
import 'package:mobile/core/providers.dart';
import 'package:mobile/features/settings/data/app_settings.dart';
import 'package:mobile/features/settings/data/settings_providers.dart';
import 'package:mobile/shared/constants/app_colors.dart';
import 'package:mobile/shared/widgets/app_scaffold.dart';
import 'package:mobile/shared/widgets/primary_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _feeFixed = TextEditingController();
  final _feePercent = TextEditingController();
  final _fromCurrency = TextEditingController(text: 'USD');
  final _toCurrency = TextEditingController(text: 'EUR');
  final _rate = TextEditingController();

  bool _seeded = false;
  bool _showRateForm = false;
  bool _saving = false;

  @override
  void dispose() {
    _feeFixed.dispose();
    _feePercent.dispose();
    _fromCurrency.dispose();
    _toCurrency.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _seed(TenantSettings settings) {
    if (_seeded) return;
    _feeFixed.text = settings.feeFixed;
    _feePercent.text = settings.feePercent;
    _seeded = true;
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    try {
      await ref.read(settingsRepositoryProvider).updateSettings(<String, String>{
        'transfer.fee.fixed': _feeFixed.text.trim(),
        'transfer.fee.percent': _feePercent.text.trim(),
      });
      ref.invalidate(tenantSettingsProvider);
      ref.read(dataVersionProvider.notifier).state++;
      _message('Configuración actualizada');
    } on ApiException catch (error) {
      _message(error.displayMessage);
    } catch (_) {
      _message('No se pudo actualizar la configuración');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _createRate() async {
    setState(() => _saving = true);
    try {
      await ref.read(settingsRepositoryProvider).createRate(
            fromCurrency: _fromCurrency.text,
            toCurrency: _toCurrency.text,
            rate: _rate.text,
            effectiveFrom: DateTime.now().toUtc().toIso8601String(),
          );
      ref.invalidate(exchangeRatesProvider);
      ref.read(dataVersionProvider.notifier).state++;
      _rate.clear();
      setState(() => _showRateForm = false);
      _message('Tasa creada correctamente');
    } on ApiException catch (error) {
      _message(error.displayMessage);
    } catch (_) {
      _message('No se pudo crear la tasa');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canManage =
        ref.watch(sessionControllerProvider).value?.user.canManageSettings ?? false;
    final settingsAsync = ref.watch(tenantSettingsProvider);
    final ratesAsync = ref.watch(exchangeRatesProvider);
    final settings = settingsAsync.value;
    if (settings != null) _seed(settings);
    final rates = ratesAsync.value ?? const [];

    return AppScaffold(
      title: 'Configuración y tasas',
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Comisiones de transferencia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (settingsAsync.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (settingsAsync.hasError)
                    Text(
                      'No se pudo cargar la configuración: ${settingsAsync.error}',
                      style: const TextStyle(color: AppColors.danger),
                    )
                  else ...[
                    TextField(
                      controller: _feeFixed,
                      enabled: canManage,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Comisión fija (transfer.fee.fixed)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _feePercent,
                      enabled: canManage,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Comisión porcentual (transfer.fee.percent)',
                      ),
                    ),
                    if (canManage) ...[
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: 'Guardar configuración',
                        icon: Icons.save_outlined,
                        loading: _saving,
                        onPressed: _saveSettings,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tasas de cambio',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: () => setState(() => _showRateForm = !_showRateForm),
                  icon: const Icon(Icons.add),
                  label: Text(_showRateForm ? 'Ocultar' : 'Nueva'),
                ),
            ],
          ),
          if (_showRateForm && canManage) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _fromCurrency,
                            decoration: const InputDecoration(labelText: 'Desde'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _toCurrency,
                            decoration: const InputDecoration(labelText: 'Hasta'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _rate,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Tasa'),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Crear tasa',
                      icon: Icons.save_outlined,
                      loading: _saving,
                      onPressed: _createRate,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (ratesAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (ratesAsync.hasError)
            Text(
              'No se pudieron cargar las tasas: ${ratesAsync.error}',
              style: const TextStyle(color: AppColors.danger),
            )
          else if (rates.isEmpty)
            const Text(
              'Este banco todavía no tiene tasas de cambio',
              style: TextStyle(color: AppColors.textSecondary),
            )
          else
            ...rates.map(
              (rate) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.surfaceMuted,
                    child: Icon(Icons.swap_horiz, color: AppColors.primary),
                  ),
                  title: Text(
                    rate.pair,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text('Tasa: ${rate.rate}'),
                  trailing: Text(
                    rate.active ? 'Vigente' : 'Inactiva',
                    style: TextStyle(
                      fontSize: 12,
                      color: rate.active ? AppColors.success : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
