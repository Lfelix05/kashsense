import 'package:flutter/material.dart';
import 'package:kashsense/models/transaction_model.dart';
import 'package:kashsense/services/database.dart';

import '../widgets/add_transaction.dart';

class TransactionScreen extends StatefulWidget {
  final String userId;

  const TransactionScreen({super.key, required this.userId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _formatCategory(TransactionCategory category) {
    return category.toString().split('.').last;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  double _getTotalExpenses(List<Transaction> transactions) {
    return transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0.0, (total, transaction) => total + transaction.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transações',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'JetBrains Mono',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 113, 113),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Transaction>>(
          stream: Database.watchTransactions(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar transações'));
            }

            final transactions = snapshot.data ?? [];
            final totalExpenses = _getTotalExpenses(transactions);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.redAccent,
                        Color.fromARGB(255, 181, 177, 177),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Minhas Transações',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total de gastos:'),
                              const SizedBox(height: 4),
                              Text(
                                'R\$ ${totalExpenses.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: transactions.isEmpty
                        ? const Center(
                            child: Text('Nenhuma transação encontrada'),
                          )
                        : ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) {
                              final transaction = transactions[index];
                              return ListTile(
                                leading: Icon(
                                  transaction.type == TransactionType.income
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color:
                                      transaction.type == TransactionType.income
                                      ? Colors.green
                                      : Colors.redAccent,
                                ),
                                title: Text(transaction.title),
                                subtitle: Text(
                                  transaction.type == TransactionType.income &&
                                          transaction.title == 'Adição de saldo'
                                      ? 'R\$ ${transaction.amount.toStringAsFixed(2)} - Adição de saldo'
                                      : 'R\$ ${transaction.amount.toStringAsFixed(2)} - ${_formatCategory(transaction.category)}',
                                ),
                                trailing: Text(_formatDate(transaction.date)),
                                iconColor:
                                    transaction.type == TransactionType.income
                                    ? Colors.green
                                    : Colors.redAccent,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) =>
                buildAddTransaction(context, userId: widget.userId),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color.fromARGB(255, 255, 113, 113),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
