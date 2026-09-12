import 'package:flutter/material.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../models/user_settings.dart';
import '../services/database.dart';

class SecuritySett extends StatefulWidget {
  final String userId;

  const SecuritySett({super.key, required this.userId});

  @override
  State<SecuritySett> createState() => _SecuritySettState();
}

class _SecuritySettState extends State<SecuritySett> {
  UserSettings? _settings;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await Database.getSettings(widget.userId);
    if (!mounted) return;
    setState(() {
      _settings = settings;
    });
  }

  Future<void> _save() async {
    final settings = _settings;
    if (settings == null) return;
    try {
      await Database.setSettings(widget.userId, settings);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferência salva.'),
          duration: Duration(milliseconds: 1200),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar preferência.')),
      );
    }
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
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Segurança'),
        automaticallyImplyLeading: false,
      ),
      body: AppBackground(
        child: settings == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  getBottomSafePadding(context),
                ),
                children: [
                  _sectionTitle('Aparência'),
                  _toggleTile(
                    title: 'Modo escuro',
                    subtitle: 'Troca o tema do aplicativo para escuro.',
                    value: settings.isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        settings.isDarkMode = value;
                      });
                      appDarkModeNotifier.value = value;
                      _save();
                    },
                  ),
                  const SizedBox(height: 10),
                  _sectionTitle('Acesso ao aplicativo'),
                  _toggleTile(
                    title: 'Bloqueio biométrico',
                    subtitle: 'Exige digital ou reconhecimento facial para entrar.',
                    value: settings.biometricLock,
                    chipLabel: 'Em breve',
                    onChanged: (value) {
                      setState(() {
                        settings.biometricLock = value;
                      });
                      _save();
                    },
                  ),
                  _toggleTile(
                    title: 'PIN de acesso',
                    subtitle: 'Exige um código numérico para abrir o app.',
                    value: settings.pinEnabled,
                    chipLabel: 'Em breve',
                    onChanged: (value) {
                      setState(() {
                        settings.pinEnabled = value;
                      });
                      _save();
                    },
                  ),
                  const SizedBox(height: 10),
                  _sectionTitle('Privacidade'),
                  _toggleTile(
                    title: 'Ocultar valores',
                    subtitle: 'Esconde saldos e valores por padrão na tela.',
                    value: settings.hideValues,
                    onChanged: (value) {
                      setState(() {
                        settings.hideValues = value;
                      });
                      _save();
                    },
                  ),
                  _toggleTile(
                    title: 'Ocultar conteúdo nas notificações',
                    subtitle: 'Evita exibir valores na tela de bloqueio.',
                    value: settings.hideNotificationContent,
                    onChanged: (value) {
                      setState(() {
                        settings.hideNotificationContent = value;
                      });
                      _save();
                    },
                  ),
                ],
              ),
      ),
    );
  }
}
