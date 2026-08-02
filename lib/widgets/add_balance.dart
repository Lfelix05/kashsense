import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';

import '../models/transaction_model.dart';
import '../theme/app_theme.dart';

class BalanceAddition {
  final double amount;
  final TransactionCategory category;

  const BalanceAddition({required this.amount, required this.category});
}

class _BankCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '0,00',
        selection: TextSelection.collapsed(offset: 4),
      );
    }

    final value = int.parse(digits);
    final cents = value % 100;
    final whole = value ~/ 100;
    final wholeFormatted = whole.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    final formatted = '$wholeFormatted,${cents.toString().padLeft(2, '0')}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

double _parseCurrencyText(String text) {
  final digits = text.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return 0;
  }
  return int.parse(digits) / 100;
}

void _moveCursorToEnd(TextEditingController controller) {
  controller.selection = TextSelection.collapsed(
    offset: controller.text.length,
  );
}

Widget buildAddBalance(BuildContext context) {
  return const _AddBalanceSheet();
}

class _AddBalanceSheet extends StatefulWidget {
  const _AddBalanceSheet();

  @override
  State<_AddBalanceSheet> createState() => _AddBalanceSheetState();
}

class _AddBalanceSheetState extends State<_AddBalanceSheet> {
  late final TextEditingController amountController;
  TransactionCategory selectedCategory = TransactionCategory.salario;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: '0,00');
    _moveCursorToEnd(amountController);
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottomPadding = getBottomSafePadding(context);

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          bottomInset + safeBottomPadding,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar Saldo',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.end,
                  onTap: () => _moveCursorToEnd(amountController),
                  onChanged: (_) => _moveCursorToEnd(amountController),
                  decoration: InputDecoration(
                    prefixText: 'R\$ ',
                    hintText: '0,00',
                    hintStyle: const TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.black87),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_BankCurrencyInputFormatter()],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Categoria',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 4),
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: TransactionCategory.values
                      .where(
                        (category) =>
                            category == TransactionCategory.salario ||
                            category == TransactionCategory.investimentos,
                      )
                      .map(
                        (category) => DropdownMenuItem<TransactionCategory>(
                          value: category,
                          child: Text(_categoryLabel(category)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () {
                    final parsedAmount = _parseCurrencyText(
                      amountController.text,
                    );
                    if (parsedAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Digite um valor valido para adicionar.',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(
                      context,
                      BalanceAddition(
                        amount: parsedAmount,
                        category: selectedCategory,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(TransactionCategory category) {
  switch (category) {
    case TransactionCategory.comida:
      return 'Comida';
    case TransactionCategory.transporte:
      return 'Transporte';
    case TransactionCategory.lazer:
      return 'Lazer';
    case TransactionCategory.saude:
      return 'Saude';
    case TransactionCategory.contas:
      return 'Contas';
    case TransactionCategory.salario:
      return 'Salário';
    case TransactionCategory.investimentos:
      return 'Investimentos';
    case TransactionCategory.outros:
      return 'Outros';
  }
}
