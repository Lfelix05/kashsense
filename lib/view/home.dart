import 'package:flutter/material.dart';
import '../services/database.dart';
import 'login.dart';
import 'register.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'KashSense',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Seu aplicativo de controle financeiro pessoal',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6200EE),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterView(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: const Text(
                          'Registrar',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '© 2024 KashSense. Todos os direitos reservados.',
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              ListView(
                shrinkWrap: true,
                children: [
                  Database.users.isEmpty
                      ? const Text('Nenhum usuário registrado.')
                      : Column(
                          children: Database.users.map((user) {
                            return ListTile(
                              title: Text(user.name),
                              subtitle: Text(user.email),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
