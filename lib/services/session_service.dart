import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'package:flutter/material.dart';
import '../theme/theme_controller.dart';
import '../view/home.dart';
import 'database.dart';

// Navigator raiz do app, usado para trocar de tela fora de um BuildContext
// (ex.: sair da conta a partir da tela de bloqueio).
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

// true enquanto a tela de PIN estiver cobrindo o app.
final ValueNotifier<bool> appLockedNotifier = ValueNotifier<bool>(false);

// true quando saldos e valores devem aparecer mascarados.
final ValueNotifier<bool> hideValuesNotifier = ValueNotifier<bool>(false);

const String hiddenValueMask = 'R\$ •••••';

class SessionService {
  SessionService._();

  // Aplica as preferências visuais do usuário (tema e ocultar valores).
  static Future<void> applyUserSettings(String userId) async {
    final settings = await Database.getSettings(userId);
    appDarkModeNotifier.value = settings.isDarkMode;
    hideValuesNotifier.value = settings.hideValues;
  }

  static Future<void> signOut() async {
    await fire_auth.FirebaseAuth.instance.signOut();
    appLockedNotifier.value = false;
    hideValuesNotifier.value = false;
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const Home()),
      (route) => false,
    );
  }
}
