import 'package:flutter/material.dart';
import 'summary_screen.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';


class MasterView extends StatefulWidget {
  const MasterView({super.key});

  @override
  State<MasterView> createState() => _MasterViewState();
}

class _MasterViewState extends State<MasterView> {
  int _selectedIndex = 0;

  final List<Widget> _views = [
    SummaryScreen(),
    TransactionScreen(),
    SettingsScreen(),
  ];
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
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Resumo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}