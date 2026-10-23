import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';
import '../widgets/pin_pad.dart';

// Cadastro do PIN em duas etapas (digitar e confirmar).
// Retorna true via Navigator.pop quando o PIN é salvo.
class PinSetupView extends StatefulWidget {
  final String userId;

  const PinSetupView({super.key, required this.userId});

  @override
  State<PinSetupView> createState() => _PinSetupViewState();
}

class _PinSetupViewState extends State<PinSetupView> {
  String? _firstPin;
  String? _error;

  Future<void> _onCompleted(String pin) async {
    final firstPin = _firstPin;
    if (firstPin == null) {
      setState(() {
        _firstPin = pin;
        _error = null;
      });
      return;
    }

    if (pin != firstPin) {
      setState(() {
        _firstPin = null;
        _error = 'Os PINs não coincidem. Tente novamente.';
      });
      return;
    }

    await PinService.setPin(widget.userId, pin);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final confirming = _firstPin != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Criar PIN')),
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: PinPad(
              title: confirming ? 'Confirme o PIN' : 'Crie um PIN',
              subtitle: confirming
                  ? 'Digite o mesmo PIN novamente.'
                  : 'Use ${PinService.pinLength} dígitos que só você conheça.',
              errorText: _error,
              onCompleted: _onCompleted,
            ),
          ),
        ),
      ),
    );
  }
}

// Pede o PIN atual antes de uma ação sensível (ex.: desativar o bloqueio).
// Retorna true via Navigator.pop quando o PIN confere.
class PinVerifyView extends StatefulWidget {
  final String userId;

  const PinVerifyView({super.key, required this.userId});

  @override
  State<PinVerifyView> createState() => _PinVerifyViewState();
}

class _PinVerifyViewState extends State<PinVerifyView> {
  String? _error;

  Future<void> _onCompleted(String pin) async {
    final valid = await PinService.verifyPin(widget.userId, pin);
    if (!mounted) return;
    if (valid) {
      Navigator.pop(context, true);
      return;
    }
    setState(() => _error = 'PIN incorreto.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar PIN')),
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: PinPad(
              title: 'Digite seu PIN atual',
              subtitle: 'Para desativar o bloqueio por PIN.',
              errorText: _error,
              onCompleted: _onCompleted,
            ),
          ),
        ),
      ),
    );
  }
}
