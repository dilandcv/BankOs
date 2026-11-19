import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/accounts/data/account.dart';

/// Selector reutilizable de cuentas del banco activo.
class AccountSelector extends ConsumerWidget {
  const AccountSelector({
    super.key,
    required this.accounts,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final List<AccountModel> accounts;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seenIds = <String>{};
    final uniqueAccounts =
        accounts.where((account) => seenIds.add(account.id)).toList();
    final validValue = uniqueAccounts.any((account) => account.id == value)
        ? value
        : null;

    return DropdownButtonFormField<String?>(
      value: validValue,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
      ),
      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text('Selecciona una cuenta'),
        ),
        ...uniqueAccounts.map(
          (account) => DropdownMenuItem<String?>(
            value: account.id,
            child: Text('${account.displayName} · ${account.maskedNumber}'),
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
