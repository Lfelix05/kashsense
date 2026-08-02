import 'package:flutter/material.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';
import '../theme/app_theme.dart';

class NotificationsSett extends StatefulWidget {
  const NotificationsSett({super.key});

  @override
  State<NotificationsSett> createState() => _NotificationsSettState();
}

class _NotificationsSettState extends State<NotificationsSett> {
  bool notificationsEnabled = true;
  bool closingMonthReminder = true;
  bool dueBillsReminder = true;
  bool weeklySummary = false;
  bool aboveAverageAlert = true;
  bool budgetGoalAlert = true;
  bool unusualMovementAlert = false;

  String selectedFrequency = 'Semanal';
  String selectedTime = '08:00';

  void _showSavedFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preferência salva (modo demonstração).'),
        duration: Duration(milliseconds: 1200),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontFamily: 'JetBrains Mono',
          fontWeight: FontWeight.bold,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }

  Widget _toggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? chipLabel,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (chipLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  chipLabel,
                  style: const TextStyle(
                    color: AppColors.chipText,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle),
        ),
        trailing: Switch(
          value: value,
          onChanged: (newValue) {
            onChanged(newValue);
            _showSavedFeedback();
          },
        ),
      ),
    );
  }

  Widget _dropdownSelector({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelText: title,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
          items: options
              .map(
                (option) =>
                    DropdownMenuItem(value: option, child: Text(option)),
              )
              .toList(),
          onChanged: (newValue) {
            onChanged(newValue);
            if (newValue != null) {
              _showSavedFeedback();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        automaticallyImplyLeading: false,
      ),
      body: AppBackground(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            getBottomSafePadding(context),
          ),
          children: [
            Card(
              child: ListTile(
                title: const Text(
                  'Ativar notificações',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Controle geral das mensagens do aplicativo.',
                ),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                    _showSavedFeedback();
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Lembretes financeiros'),
            _toggleTile(
              title: 'Fechamento do mês',
              subtitle: 'Resumo com principais entradas e saídas.',
              value: closingMonthReminder,
              chipLabel: 'Recomendado',
              onChanged: (value) {
                setState(() {
                  closingMonthReminder = value;
                });
              },
            ),
            _toggleTile(
              title: 'Vencimento de contas',
              subtitle: 'Alerta 24h antes do prazo informado.',
              value: dueBillsReminder,
              onChanged: (value) {
                setState(() {
                  dueBillsReminder = value;
                });
              },
            ),
            _toggleTile(
              title: 'Resumo semanal',
              subtitle: 'Comparativo de gastos e receitas da semana.',
              value: weeklySummary,
              onChanged: (value) {
                setState(() {
                  weeklySummary = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _sectionTitle('Alertas inteligentes'),
            _toggleTile(
              title: 'Gastos acima da média',
              subtitle: 'Detecta aumento fora do seu padrão.',
              value: aboveAverageAlert,
              chipLabel: 'Novo',
              onChanged: (value) {
                setState(() {
                  aboveAverageAlert = value;
                });
              },
            ),
            _toggleTile(
              title: 'Meta de orçamento atingida',
              subtitle: 'Aviso ao chegar perto do limite mensal.',
              value: budgetGoalAlert,
              onChanged: (value) {
                setState(() {
                  budgetGoalAlert = value;
                });
              },
            ),
            _toggleTile(
              title: 'Movimentação incomum',
              subtitle: 'Notifica lançamentos fora do comportamento esperado.',
              value: unusualMovementAlert,
              chipLabel: 'Beta',
              onChanged: (value) {
                setState(() {
                  unusualMovementAlert = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _sectionTitle('Preferências de envio'),
            _dropdownSelector(
              title: 'Frequência',
              value: selectedFrequency,
              options: const ['Diária', 'Semanal', 'Mensal'],
              onChanged: (value) {
                setState(() {
                  selectedFrequency = value ?? selectedFrequency;
                });
              },
            ),
            _dropdownSelector(
              title: 'Horário preferido',
              value: selectedTime,
              options: const ['08:00', '12:00', '18:00', '20:00'],
              onChanged: (value) {
                setState(() {
                  selectedTime = value ?? selectedTime;
                });
              },
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Text(
                'Você receberá no máximo 3 alertas por dia para evitar excesso de notificações.',
                style: TextStyle(color: AppColors.chipText),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prévia da notificação',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '"Você gastou 22% a mais em alimentação nesta semana."',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
