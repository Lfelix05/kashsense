import 'package:flutter/material.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';
import '../theme/app_theme.dart';

class SecuritySett extends StatefulWidget {
  const SecuritySett({super.key});

  @override
  State<SecuritySett> createState() => _SecuritySettState();
}

class _SecuritySettState extends State<SecuritySett> {
  bool biometricLock = true;
  bool pinEnabled = true;
  bool hideValues = false;
  bool hideNotificationContent = true;

  String timeout = '5 min';

  void _showSavedFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuração atualizada (modo demonstração).'),
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

  Widget _settingCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segurança'),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user, color: AppColors.primary),
                        SizedBox(width: 8),
                        Text(
                          'Nível de segurança: Bom',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: const LinearProgressIndicator(
                        value: 0.72,
                        minHeight: 9,
                        color: AppColors.primary,
                        backgroundColor: AppColors.primarySoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ative todos os recursos para chegar ao nível Excelente.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _sectionTitle('Acesso'),
            _settingCard(
              title: 'Bloqueio por biometria',
              subtitle:
                  'Use digital/face para entrar mais rápido e com segurança.',
              value: biometricLock,
              onChanged: (value) {
                setState(() {
                  biometricLock = value;
                });
              },
            ),
            _settingCard(
              title: 'PIN de 6 dígitos',
              subtitle:
                  'Solicita PIN ao abrir o app após período de inatividade.',
              value: pinEnabled,
              onChanged: (value) {
                setState(() {
                  pinEnabled = value;
                });
              },
            ),
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: timeout,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Timeout automático',
                    labelStyle: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  items: const ['1 min', '5 min', '10 min']
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      timeout = value ?? timeout;
                    });
                    _showSavedFeedback();
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            _sectionTitle('Privacidade'),
            _settingCard(
              title: 'Ocultar valores na tela inicial',
              subtitle: 'Esconde saldos e números sensíveis com um toque.',
              value: hideValues,
              onChanged: (value) {
                setState(() {
                  hideValues = value;
                });
              },
            ),
            _settingCard(
              title: 'Ocultar conteúdo nas notificações',
              subtitle: 'Mostra apenas alerta genérico na tela bloqueada.',
              value: hideNotificationContent,
              onChanged: (value) {
                setState(() {
                  hideNotificationContent = value;
                });
              },
            ),
            const SizedBox(height: 10),
            _sectionTitle('Sessões e dispositivos'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dispositivo atual',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text('Android • Último acesso: agora'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _showSavedFeedback,
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        'Encerrar sessões em outros dispositivos',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            _sectionTitle('Atividade recente'),
            Card(
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.login, color: Colors.green),
                      title: Text('Login bem-sucedido'),
                      subtitle: Text('Hoje, 09:42'),
                    ),
                    Divider(height: 8),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.pin, color: AppColors.primary),
                      title: Text('PIN alterado'),
                      subtitle: Text('Ontem, 18:10'),
                    ),
                    Divider(height: 8),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.shield, color: Colors.orange),
                      title: Text('Tentativa bloqueada'),
                      subtitle: Text('Há 3 dias, 21:03'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _showSavedFeedback,
              icon: const Icon(Icons.download),
              label: const Text('Baixar relatório de segurança'),
            ),
          ],
        ),
      ),
    );
  }
}
