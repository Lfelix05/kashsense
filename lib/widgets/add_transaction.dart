import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../providers/providers.dart';

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
  TransactionCategory selectedCategory = TransactionCategory.outros;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  amountController.text = '0,00';
  _moveCursorToEnd(amountController);
  final bottomInset = MediaQuery.of(context).viewInsets.bottom;

  return SafeArea(
    top: false,
    child: AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 16),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Adicionar Transação',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
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
                decoration: InputDecoration(
                  prefixText: 'R\$ ',
                  labelText: 'Valor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setLocalState) {
                  return DropdownButtonFormField<TransactionCategory>(
                    initialValue: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: TransactionCategory.values
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
                      setLocalState(() {
                        selectedCategory = value;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                      userId,
                      titleController.text,
                      parsedAmount,
                      DateTime.now(),
                      TransactionType.expense,
                      selectedCategory,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 69, 69),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
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
      return 'Salario';
    case TransactionCategory.outros:
      return 'Outros';
  }
}
