import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kashsense/models/transaction_model.dart';
import 'package:kashsense/services/database.dart';

Widget monthGraph({required String userId}) {
  return StreamBuilder<List<Transaction>>(
    stream: Database.watchTransactions(userId),
    builder: (context, snapshot) {
      final transactions = snapshot.data ?? const <Transaction>[];
      final now = DateTime.now();

      final currentMonthTransactions = transactions.where((transaction) {
        return transaction.date.year == now.year &&
            transaction.date.month == now.month;
      });

      double income = 0;
      double expense = 0;

      for (final transaction in currentMonthTransactions) {
        if (transaction.type == TransactionType.income) {
          income += transaction.amount;
        } else {
          expense += transaction.amount;
        }
      }

      final total = income + expense;
      final hasData = total > 0;

      final incomePercentage = hasData ? (income / total) * 100 : 0.0;
      final expensePercentage = hasData ? (expense / total) * 100 : 0.0;

      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Visão Geral do Mês',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: hasData
                  ? PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: [
                          if (income > 0)
                            PieChartSectionData(
                              value: income,
                              title: '${incomePercentage.toStringAsFixed(0)}%',
                              color: Colors.green[600],
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                          if (expense > 0)
                            PieChartSectionData(
                              value: expense,
                              title: '${expensePercentage.toStringAsFixed(0)}%',
                              color: Colors.red[400],
                              radius: 60,
                              titleStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'JetBrains Mono',
                              ),
                            ),
                        ],
                      ),
                    )
                  : Center(
                      child: Text(
                        'Sem movimentações neste mês',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Colors.green[600]!, label: 'Receitas'),
                const SizedBox(width: 24),
                _LegendDot(color: Colors.red[400]!, label: 'Despesas'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Icon(Icons.arrow_upward, color: Colors.green),
                    const SizedBox(height: 4),
                    Text('Receitas', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(income),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Icon(Icons.arrow_downward, color: Colors.red),
                    const SizedBox(height: 4),
                    Text('Despesas', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(expense),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

String _formatCurrency(double value) {
  final fixed = value.toStringAsFixed(2).split('.');
  final integerPart = fixed[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return 'R\$ $integerPart,${fixed[1]}';
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
