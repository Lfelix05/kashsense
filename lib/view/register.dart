import 'package:flutter/material.dart';
import '../services/database.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _register() async {
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Database.addUser(name, email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar')),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
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
                    'Registrar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 28),
                  TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Nome',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.email),
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: _emailController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.lock),
                      labelText: 'Senha',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      _register();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6200EE),
                      minimumSize: const Size(240, 48),
                    ),
                    child: const Text(
                      'Registrar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
