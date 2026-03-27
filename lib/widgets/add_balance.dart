import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';

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
              color: Colors.blueAccent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Adicionar Saldo',
                  style: TextStyle(
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
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [_BankCurrencyInputFormatter()],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
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

                      Navigator.pop(context, parsedAmount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Adicionar',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
