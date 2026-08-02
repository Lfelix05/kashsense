import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("As senhas não coincidem.")));
        return;
      }
      try {
        final userCredential = await fire_auth.FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );

        final newUser = User(
          id: userCredential.user!.uid,
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          profilePictureUrl: null,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(newUser.id)
            .set(newUser.toJson());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginView()),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erro ao registrar: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final passwordStrength = _passwordStrengthValue(_passwordController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
        backgroundColor: AppColors.backgroundStart,
        foregroundColor: AppColors.primaryDark,
        titleTextStyle: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: AppColors.primaryDark,
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(gradient: AppGradients.background),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                    side: const BorderSide(color: AppColors.cardBorder),
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
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Comece a organizar seus gastos e metas em poucos passos.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: TextField(
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              labelText: 'Nome',
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            labelText: 'Email',
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
                            color: AppColors.textFaint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Use no mínimo 6 caracteres e combine letras e números.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textFaint,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) =>
                              _isSubmitting ? null : _register(),
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.lock_outline),
                            labelText: 'Confirmar senha',
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isSubmitting ? null : _register,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Registrar'),
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
