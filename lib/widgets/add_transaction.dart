import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'safe_area_condition.dart';

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

Widget buildAddTransaction(BuildContext context, {required String userId}) {
  return _AddTransactionSheet(userId: userId);
}

class _AddTransactionSheet extends StatefulWidget {
  final String userId;

  const _AddTransactionSheet({required this.userId});

  @override
  State<_AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<_AddTransactionSheet> {
  late final TextEditingController titleController;
  late final TextEditingController amountController;
  TransactionCategory selectedCategory = TransactionCategory.outros;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    amountController = TextEditingController(text: '0,00');
    _moveCursorToEnd(amountController);
  }

  @override
  void dispose() {
    titleController.dispose();
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: const Border.fromBorderSide(
                BorderSide(color: AppColors.cardBorder),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Adicionar Transação',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    color: AppColors.primaryDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textAlign: TextAlign.end,
                  onTap: () => _moveCursorToEnd(amountController),
                  onChanged: (_) => _moveCursorToEnd(amountController),
                  inputFormatters: [_BankCurrencyInputFormatter()],
                  decoration: const InputDecoration(
                    prefixText: 'R\$ ',
                    labelText: 'Valor',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TransactionCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Categoria'),
                  items: TransactionCategory.values
                      .where(
                        (category) =>
                            category != TransactionCategory.salario &&
                            category != TransactionCategory.investimentos &&
                            category != TransactionCategory.beneficios,
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
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () {
                    final parsedAmount = _parseCurrencyText(
                      amountController.text,
                    );

                    if (titleController.text.isEmpty || parsedAmount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Preencha todos os campos corretamente',
                          ),
                        ),
                      );
                      return;
                    }
                    addTransaction(
                      widget.userId,
                      titleController.text,
                      parsedAmount,
                      DateTime.now(),
                      TransactionType.expense,
                      selectedCategory,
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.danger,
                  ),
                  child: const Text('Salvar'),
                ),
                const SizedBox(height: 16),
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
    case TransactionCategory.beneficios:
      return 'Benefícios';
    case TransactionCategory.outros:
      return 'Outros';
  }
}
