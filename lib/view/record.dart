import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kashsense/models/transaction_model.dart';
import 'package:kashsense/services/database.dart';

class RecordView extends StatefulWidget {
  final String userId;

  const RecordView({super.key, required this.userId});

  @override
  State<RecordView> createState() => _RecordViewState();
}

class _RecordViewState extends State<RecordView> {
  static const Map<TransactionCategory, String> _categoryLabels = {
    TransactionCategory.comida: 'Comida',
    TransactionCategory.transporte: 'Transporte',
    TransactionCategory.lazer: 'Lazer',
    TransactionCategory.saude: 'Saude',
    TransactionCategory.contas: 'Contas',
    TransactionCategory.salario: 'Salario',
    TransactionCategory.outros: 'Outros',
  };

  static const Map<TransactionCategory, Color> _categoryColors = {
    TransactionCategory.comida: Color(0xFF4CAF50),
    TransactionCategory.transporte: Color(0xFF2196F3),
    TransactionCategory.lazer: Color(0xFFFF9800),
    TransactionCategory.saude: Color(0xFFE91E63),
    TransactionCategory.contas: Color(0xFF9C27B0),
    TransactionCategory.salario: Color(0xFF009688),
    TransactionCategory.outros: Color(0xFF795548),
  };

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  String _formatCurrency(double value) {
    final fixed = value.toStringAsFixed(2).split('.');
    final integerPart = fixed[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );
    return 'R\$ $integerPart,${fixed[1]}';
  }

  List<BarChartRodStackItem> _buildStackItems(
    Map<TransactionCategory, double> values,
  ) {
    final items = <BarChartRodStackItem>[];
    double accumulated = 0;

    for (final category in TransactionCategory.values) {
      final amount = values[category] ?? 0;
      if (amount <= 0) {
        continue;
      }

      final start = accumulated;
      final end = start + amount;
      items.add(BarChartRodStackItem(start, end, _categoryColors[category]!));
      accumulated = end;
    }

    return items;
  }

  void _showCategoryDetails(
    TransactionCategory category,
    Map<TransactionCategory, double> incomeByCategory,
    Map<TransactionCategory, double> expenseByCategory,
  ) {
    final income = incomeByCategory[category] ?? 0;
    final expense = expenseByCategory[category] ?? 0;
    final total = income + expense;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryLabels[category]!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Receitas: ${_formatCurrency(income)}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'Despesas: ${_formatCurrency(expense)}',
                  style: const TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total movimentado: ${_formatCurrency(total)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Gasto total da categoria: ${_formatCurrency(expense)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend(
    Map<TransactionCategory, double> incomeByCategory,
    Map<TransactionCategory, double> expenseByCategory,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TransactionCategory.values.map((category) {
        final hasData =
            (incomeByCategory[category] ?? 0) > 0 ||
            (expenseByCategory[category] ?? 0) > 0;

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showCategoryDetails(
            category,
            incomeByCategory,
            expenseByCategory,
          ),
          child: Opacity(
            opacity: hasData ? 1 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _categoryColors[category]!.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _categoryColors[category]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _categoryColors[category],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _categoryLabels[category]!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      value == 0 ? '0' : value.toStringAsFixed(0),
      style: const TextStyle(fontSize: 10, color: Colors.black54),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'JetBrains Mono',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 113, 113),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<List<Transaction>>(
        stream: Database.watchTransactions(widget.userId),
        builder: (context, snapshot) {
          final transactions = snapshot.data ?? const <Transaction>[];
          final monthTransactions = transactions
              .where((transaction) => _isCurrentMonth(transaction.date))
              .toList();

          final incomeByCategory = {
            for (final category in TransactionCategory.values) category: 0.0,
          };
          final expenseByCategory = {
            for (final category in TransactionCategory.values) category: 0.0,
          };

          for (final transaction in monthTransactions) {
            if (transaction.type == TransactionType.income) {
              incomeByCategory[transaction.category] =
                  (incomeByCategory[transaction.category] ?? 0) +
                  transaction.amount;
            } else {
              expenseByCategory[transaction.category] =
                  (expenseByCategory[transaction.category] ?? 0) +
                  transaction.amount;
            }
          }

          final totalIncome = incomeByCategory.values.fold(
            0.0,
            (sum, value) => sum + value,
          );
          final totalExpense = expenseByCategory.values.fold(
            0.0,
            (sum, value) => sum + value,
          );

          final maxTotal = math.max(totalIncome, totalExpense).toDouble();
          final maxY = maxTotal <= 0 ? 100.0 : maxTotal * 1.2;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mês Atual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Receitas x Despesas por categoria',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                    child: SizedBox(
                      height: 360,
                      child: BarChart(
                        BarChartData(
                          maxY: maxY,
                          minY: 0,
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 34,
                                interval: maxY / 4,
                                getTitlesWidget: _leftTitleWidgets,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String text = '';
                                  if (value == 0) {
                                    text = 'Receitas';
                                  } else if (value == 1) {
                                    text = 'Despesas';
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      text,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: totalIncome,
                                  width: 48,
                                  borderRadius: BorderRadius.circular(4),
                                  rodStackItems: _buildStackItems(
                                    incomeByCategory,
                                  ),
                                  color: const Color.fromARGB(255, 233, 255, 223).withOpacity(0.35),
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: totalExpense,
                                  width: 48,
                                  borderRadius: BorderRadius.circular(4),
                                  rodStackItems: _buildStackItems(
                                    expenseByCategory,
                                  ),
                                  color: const Color.fromARGB(255, 233, 218, 218).withOpacity(0.35),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total income: ${_formatCurrency(totalIncome)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total expenses: ${_formatCurrency(totalExpense)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Categorias (toque para detalhes)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                _buildLegend(incomeByCategory, expenseByCategory),
                if (monthTransactions.isEmpty) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Sem movimentações neste mês para exibir no gráfico.',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
