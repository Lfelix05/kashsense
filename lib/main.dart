import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '../view/home.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../view/master.dart';
import '../services/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> initialscreen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    // Determina a tela inicial
    if (userId != null) {
      final settings = await Database.getSettings(userId);
      appDarkModeNotifier.value = settings.isDarkMode;
      return MasterView(
        userId: userId,
        userName: prefs.getString('userName') ?? '',
      );
    } else {
      return const Home();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          theme: buildAppTheme(),
          darkTheme: buildAppDarkTheme(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: FutureBuilder<Widget>(
            future: initialscreen(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!;
              } else {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );
      },
    );
  }
}
