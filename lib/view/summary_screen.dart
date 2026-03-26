import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kashsense/services/database.dart';
import 'package:kashsense/widgets/action_button.dart';
import 'package:kashsense/widgets/month_graph.dart';
import '../providers/providers.dart';
import 'record.dart';
import '../widgets/add_balance.dart';
import '../widgets/add_transaction.dart';
import '../widgets/budget_progress.dart';

class SummaryScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const SummaryScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  double _currentBalance = 0;

  ImageProvider<Object>? _buildProfilePhoto(String? photoBase64) {
    if (photoBase64 == null || photoBase64.isEmpty) {
      return null;
    }

    try {
      final bytes = base64Decode(photoBase64);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final balance = await getBalanceForUser(widget.userId);
    if (!mounted) {
      return;
    }
    setState(() {
      _currentBalance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Database.getUserById(widget.userId);
    final displayName = currentUser?.name ?? widget.userName;
    final profilePhoto = _buildProfilePhoto(currentUser?.profilePictureUrl);

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
                          'Olá, $displayName!',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'JetBrains Mono',
                            color: Colors.white,
                          ),
                        ),
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: profilePhoto,
                          backgroundColor: Colors.white.withOpacity(0.85),
                          child: profilePhoto == null
                              ? const Icon(
                                  Icons.account_circle,
                                  size: 28,
                                  color: Colors.black54,
                                )
                              : null,
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
                  child: monthGraph(userId: widget.userId),
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
                            onTap: () async {
                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => buildAddTransaction(
                                  context,
                                  userId: widget.userId,
                                ),
                              );
                              await _loadBalance();
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
                                widget.userId,
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
                                  builder: (context) =>
                                      RecordView(userId: widget.userId),
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
                    userId: widget.userId,
                    label: 'Orçamento Mensal',
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
