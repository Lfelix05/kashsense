import 'package:flutter/material.dart';
import 'package:kashsense/view/notifications_sett.dart';
import 'package:kashsense/view/security_sett.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';
import '../theme/app_theme.dart';
import 'profile.dart';

class SettingsScreen extends StatefulWidget {
  final String? userId;
  final String? userName;

  const SettingsScreen({super.key, this.userId, this.userName});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        automaticallyImplyLeading: false,
      ),
      body: AppBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              getBottomSafePadding(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: const Text('Perfil'),
                        subtitle: const Text(
                          'Gerencie suas informações pessoais',
                        ),
                        onTap: () {
                          final userId = widget.userId;
                          if (userId == null || userId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Usuário não identificado. Faça login novamente.',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfileSetting(userId: userId),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notificações'),
                        subtitle: const Text(
                          'Configure suas preferências de notificações',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsSett(),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Segurança'),
                        subtitle: const Text(
                          'Gerencie suas configurações de segurança',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SecuritySett(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
