import 'package:flutter/material.dart';
import '../services/session_service.dart';

// Texto de valor monetário que respeita a opção "ocultar valores".
// O suffix (ex.: categoria) continua visível mesmo com o valor oculto.
class MaskedText extends StatelessWidget {
  final String text;
  final String suffix;
  final TextStyle? style;

  const MaskedText(this.text, {super.key, this.suffix = '', this.style});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: hideValuesNotifier,
      builder: (context, hidden, _) {
        return Text('${hidden ? hiddenValueMask : text}$suffix', style: style);
      },
    );
  }
}
