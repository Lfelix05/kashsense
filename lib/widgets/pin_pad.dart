import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../theme/app_theme.dart';

// Teclado numérico com indicador de dígitos. Não usa TextField nem Tooltip
// porque também é exibido na tela de bloqueio, que fica fora do Navigator.
class PinPad extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? errorText;
  // Chamado ao completar o PIN; os dígitos são limpos em seguida.
  final Future<void> Function(String pin) onCompleted;

  const PinPad({
    super.key,
    required this.title,
    this.subtitle,
    this.errorText,
    required this.onCompleted,
  });

  @override
  State<PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<PinPad> {
  String _pin = '';
  bool _busy = false;

  Future<void> _onDigit(String digit) async {
    if (_busy || _pin.length >= PinService.pinLength) return;
    setState(() => _pin += digit);
    if (_pin.length < PinService.pinLength) return;

    setState(() => _busy = true);
    await widget.onCompleted(_pin);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
    });
  }

  void _onBackspace() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Widget _key({required Widget child, required VoidCallback onTap}) {
    return SizedBox(
      width: 76,
      height: 76,
      child: InkResponse(
        onTap: onTap,
        radius: 38,
        child: Center(child: child),
      ),
    );
  }

  Widget _digitKey(String digit) {
    return _key(
      onTap: () => _onDigit(digit),
      child: Text(
        digit,
        style: TextStyle(
          fontSize: 28,
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.w500,
          color: AppColors.headingOf(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontFamily: 'JetBrains Mono',
            fontWeight: FontWeight.bold,
            color: AppColors.headingOf(context),
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMutedOf(context)),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(PinService.pinLength, (index) {
            final filled = index < _pin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: filled ? AppColors.primary : Colors.transparent,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
            );
          }),
        ),
        SizedBox(
          height: 36,
          child: Center(
            child: Text(
              widget.errorText ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.danger, fontSize: 13),
            ),
          ),
        ),
        for (final row in rows)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [for (final digit in row) _digitKey(digit)],
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 76, height: 76),
            _digitKey('0'),
            _key(
              onTap: _onBackspace,
              child: Icon(
                Icons.backspace_outlined,
                color: AppColors.textMutedOf(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
