import 'package:flutter/material.dart';

class BudgetProgress extends StatelessWidget {
  final String label;
  final double spent;
  final double limit;

  const BudgetProgress({
    required this.label,
    required this.spent,
    required this.limit,
  });

  Color _barColor(double ratio) {
    if (ratio >= 0.9) return Colors.red;
    if (ratio >= 0.65) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final ratio = (spent / limit).clamp(0.0, 1.0);
    final pct = (ratio * 100).toStringAsFixed(0);
    final color = _barColor(ratio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '$pct%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 14,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gasto: R\$ ${spent.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'JetBrains Mono',
              ),
            ),
            Text(
              'Limite: R\$ ${limit.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        if (ratio >= 0.9) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Atenção: você está próximo do limite!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[700],
                  fontFamily: 'JetBrains Mono',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
