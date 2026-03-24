import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 113, 148, 255),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configurações',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Perfil'),
                subtitle: Text('Gerencie suas informações pessoais'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Notificações'),
                subtitle: Text('Configure suas preferências de notificações'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.lock),
                title: Text('Segurança'),
                subtitle: Text('Gerencie suas configurações de segurança'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
