import 'package:flutter/material.dart';
import 'summary_screen.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';

class MasterView extends StatefulWidget {
  final String userId;
  final String userName;

  const MasterView({super.key, required this.userId, required this.userName});

  @override
  State<MasterView> createState() => _MasterViewState();
}

class _MasterViewState extends State<MasterView> {
  int _selectedIndex = 0;

  late final List<Widget> _views;

  @override
  void initState() {
    super.initState();
    _views = [
      SummaryScreen(userId: widget.userId, userName: widget.userName),
      TransactionScreen(userId: widget.userId),
      SettingsScreen(userId: widget.userId, userName: widget.userName),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _views[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Resumo'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transações'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}
