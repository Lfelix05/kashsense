import 'package:flutter/material.dart';
import 'package:kashsense/view/notifications_sett.dart';
import 'package:kashsense/view/security_sett.dart';
import 'package:kashsense/widgets/safe_area_condition.dart';
import '../services/session_service.dart';
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
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text(
          'Você precisará entrar com email e senha novamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await SessionService.signOut();
    }
  }

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
                                  NotificationsSett(userId: userId),
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
                                  SecuritySett(userId: userId),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: AppColors.danger),
                    title: const Text(
                      'Sair da conta',
                      style: TextStyle(color: AppColors.danger),
                    ),
                    onTap: _confirmSignOut,
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
