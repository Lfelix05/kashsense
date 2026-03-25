import 'package:flutter/material.dart';
import 'package:kashsense/widgets/action_button.dart';
import 'package:kashsense/widgets/month_graph.dart';
import '../providers/providers.dart';
import 'record.dart';
import '../widgets/add_balance.dart';
import '../widgets/add_transaction.dart';
import '../widgets/budget_progress.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final String _userId = 'user123';
  double _currentBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await getBalanceForUser(_userId);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentBalance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Resumo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'JetBrains Mono',
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 42, 190, 107),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      Colors.green,
                      const Color.fromARGB(255, 181, 177, 177),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Olá, Usuário!',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'JetBrains Mono',
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.account_circle,
                          size: 48,
                          color: Colors.white70,
                        ),
                      ],
                    ),

                    SizedBox(height: 8),
                    Card(
                      elevation: 4,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saldo Atual',
                              style: TextStyle(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 66, 66, 66),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'R\$ ${_currentBalance.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[700],
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.green[700],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: monthGraph(),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ações Rápidas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          QuickActionButton(
                            icon: Icons.monetization_on,
                            label: 'Add. transação',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    buildAddTransaction(context),
                              );
                            },
                          ),
                          QuickActionButton(
                            icon: Icons.wallet,
                            label: 'Add. Saldo',
                            onTap: () async {
                              final addedAmount =
                                  await showModalBottomSheet<double>(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) =>
                                        buildAddBalance(context),
                                  );

                              if (addedAmount == null) {
                                return;
                              }

                              final newBalance = await addBalance(
                                _userId,
                                addedAmount,
                              );

                              if (!mounted) {
                                return;
                              }

                              setState(() {
                                _currentBalance = newBalance;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Saldo atualizado para R\$ ${newBalance.toStringAsFixed(2)}.',
                                  ),
                                ),
                              );
                            },
                          ),
                          QuickActionButton(
                            icon: Icons.bar_chart,
                            label: 'Relatórios',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecordView(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: BudgetProgress(
                    label: 'Orçamento Mensal',
                    spent: 1500,
                    limit: 2000,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
