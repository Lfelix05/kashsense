import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_pad.dart';

// Tela de bloqueio exibida por cima de todo o app (via MaterialApp.builder).
// Como fica fora do Navigator, não abre diálogos nem rotas.
class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  static const int _maxAttempts = 5;

  int _attempts = 0;
  String? _error;
  bool _confirmingForgot = false;

  Future<void> _checkPin(String pin) async {
    final userId = fire_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      appLockedNotifier.value = false;
      return;
    }

    if (await PinService.verifyPin(userId, pin)) {
      appLockedNotifier.value = false;
      return;
    }

    if (!mounted) return;
    _attempts++;
    if (_attempts >= _maxAttempts) {
      final messenger = ScaffoldMessenger.of(context);
      await SessionService.signOut();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Muitas tentativas. Entre novamente com sua senha.'),
        ),
      );
      return;
    }

    final remaining = _maxAttempts - _attempts;
    setState(() {
      _error = remaining == 1
          ? 'PIN incorreto. Última tentativa.'
          : 'PIN incorreto. $remaining tentativas restantes.';
    });
  }

  Future<void> _forgotPin() async {
    final userId = fire_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await PinService.removePin(userId);
    }
    await SessionService.signOut();
  }

  Widget _forgotContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Esqueceu o PIN?',
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.bold,
            color: AppColors.headingOf(context),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Para redefinir, saia da conta e entre novamente com email e '
          'senha. O PIN deste aparelho será removido.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMutedOf(context)),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _forgotPin,
          child: const Text('Sair e entrar novamente'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => setState(() => _confirmingForgot = false),
          child: const Text('Voltar'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/Icon/KashSenseIcon.png',
                        width: 72,
                        height: 72,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_confirmingForgot)
                      _forgotContent()
                    else ...[
                      PinPad(
                        title: 'Digite seu PIN',
                        subtitle: 'Para continuar no KashSense.',
                        errorText: _error,
                        onCompleted: _checkPin,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () =>
                            setState(() => _confirmingForgot = true),
                        child: const Text('Esqueci meu PIN'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
