import 'package:flutter/material.dart';
import 'package:kashsense/models/transaction_model.dart';
import 'package:kashsense/services/database.dart';

class BudgetProgress extends StatefulWidget {
  final String userId;
  final String label;

  const BudgetProgress({super.key, required this.userId, required this.label});

  @override
  State<BudgetProgress> createState() => _BudgetProgressState();
}

class _BudgetProgressState extends State<BudgetProgress> {
  static const double _defaultLimit = 2000;
  double _limit = _defaultLimit;

  @override
  void initState() {
    super.initState();
    _limit = Database.getBudgetLimit(widget.userId);
  }

  Future<void> _showSetLimitDialog() async {
    final controller = TextEditingController(
      text: _limit.toStringAsFixed(2).replaceAll('.', ','),
    );

    final newLimit = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Definir limite mensal'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Limite (R\$)',
              hintText: 'Ex.: 2500,00',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final raw = controller.text
                    .trim()
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                final parsed = double.tryParse(raw);

                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe um limite válido maior que zero.'),
                    ),
                  );
                  return;
                }

                Navigator.of(context).pop(parsed);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (newLimit == null) {
      return;
    }

    Database.setBudgetLimit(widget.userId, newLimit);
    if (!mounted) {
      return;
    }

    setState(() {
      _limit = newLimit;
    });
  }

  Color _barColor(double ratio) {
    if (ratio >= 0.9) return Colors.red;
    if (ratio >= 0.65) return Colors.orange;
    return Colors.blue;
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).split('.');
    final integerPart = fixed[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'R\$ $integerPart,${fixed[1]}';
  }

  double _monthlySpent(List<Transaction> transactions) {
    final now = DateTime.now();
    double spent = 0;

    for (final transaction in transactions) {
      final isCurrentMonth =
          transaction.date.year == now.year &&
          transaction.date.month == now.month;
      if (isCurrentMonth && transaction.type == TransactionType.expense) {
        spent += transaction.amount;
      }
    }

    return spent;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Transaction>>(
      stream: Database.watchTransactions(widget.userId),
      builder: (context, snapshot) {
        final transactions = snapshot.data ?? const <Transaction>[];
        final spent = _monthlySpent(transactions);
        final ratio = _limit > 0 ? (spent / _limit).clamp(0.0, 1.0) : 0.0;
        final pct = (ratio * 100).toStringAsFixed(0);
        final color = _barColor(ratio);

        return InkWell(
          onTap: _showSetLimitDialog,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Toque para alterar o limite mensal',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 14,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gasto: ${_formatCurrency(spent)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                  Text(
                    'Limite: ${_formatCurrency(_limit)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'JetBrains Mono',
                    ),
                  ),
                ],
              ),
              if (ratio >= 0.9) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Atenção: você está próximo do limite!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                        fontFamily: 'JetBrains Mono',
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
