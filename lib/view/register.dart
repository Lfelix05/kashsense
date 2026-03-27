import 'package:flutter/material.dart';
import '../providers/validator.dart';
import '../services/database.dart';
import 'login.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  double _passwordStrengthValue(String password) {
    if (password.isEmpty) {
      return 0;
    }
    if (password.length < 6) {
      return 0.3;
    }
    if (password.length < 10) {
      return 0.6;
    }
    return 1;
  }

  String _passwordStrengthLabel(String password) {
    final value = _passwordStrengthValue(password);
    if (value <= 0.3) {
      return 'Fraca';
    }
    if (value <= 0.6) {
      return 'Média';
    }
    return 'Forte';
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _isSubmitting = true;
    });

    if (NameValidator.validate(name) != null ||
        EmailValidator.validate(email) != null ||
        PasswordValidator.validate(password) != null) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos.')),
      );
      return;
    }

    if (Database.emailExists(email)) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este email já está cadastrado.')),
      );
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
        Database.addUser(name, email, password);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cadastro realizado com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha no cadastro: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final passwordStrength = _passwordStrengthValue(_passwordController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        backgroundColor: const Color(0xFFF4F8FF),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF4F8FF), Color(0xFFE7EEFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: Color(0xFFDCE6FF)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Crie sua conta',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF223F9B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Comece a organizar seus gastos e metas em poucos passos.',
                          style: TextStyle(color: Color(0xFF4E5D88)),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person_outline),
                            labelText: 'Nome',
                            filled: true,
                            fillColor: const Color(0xFFF9FBFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            labelText: 'Email',
                            filled: true,
                            fillColor: const Color(0xFFF9FBFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) =>
                              _isSubmitting ? null : _register(),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            labelText: 'Senha',
                            filled: true,
                            fillColor: const Color(0xFFF9FBFF),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: passwordStrength,
                            minHeight: 8,
                            color: passwordStrength <= 0.3
                                ? Colors.redAccent
                                : passwordStrength <= 0.6
                                ? Colors.orange
                                : Colors.green,
                            backgroundColor: const Color(0xFFE2E9FF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Força da senha: ${_passwordStrengthLabel(_passwordController.text)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF5C6B93),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Use no mínimo 6 caracteres e combine letras e números.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6D7B9F),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _isSubmitting ? null : _register,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2D5FD3),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Registrar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Já possui conta?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(),
                                  ),
                                );
                              },
                              child: const Text('Entrar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
