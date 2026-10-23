import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fire_auth;
import 'firebase_options.dart';
import '../view/home.dart';
import '../theme/app_theme.dart';
import '../theme/theme_controller.dart';
import '../view/master.dart';
import '../view/pin_lock.dart';
import '../services/database.dart';
import '../services/pin_service.dart';
import '../services/session_service.dart';

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  // Tempo em segundo plano a partir do qual o PIN é pedido de novo.
  static const Duration _relockAfter = Duration(seconds: 30);

  // Guardado no State para não refazer as consultas a cada troca de tema.
  late final Future<Widget> _initialScreen = _resolveInitialScreen();
  DateTime? _backgroundSince;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Widget> _resolveInitialScreen() async {
    // O Firebase Auth mantém a sessão salva no aparelho; o primeiro evento
    // já traz o usuário restaurado (ou null se ninguém estiver logado).
    final authUser = await fire_auth.FirebaseAuth.instance
        .authStateChanges()
        .first;
    if (authUser == null) {
      return const Home();
    }

    final userId = authUser.uid;
    await SessionService.applyUserSettings(userId);
    appLockedNotifier.value = await PinService.hasPin(userId);
    final user = await Database.getUserById(userId);

    return MasterView(userId: userId, userName: user?.name ?? '');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _backgroundSince ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundSince;
      _backgroundSince = null;
      if (since != null && DateTime.now().difference(since) >= _relockAfter) {
        _lockIfNeeded();
      }
    }
  }

  Future<void> _lockIfNeeded() async {
    final userId = fire_auth.FirebaseAuth.instance.currentUser?.uid;
    if (userId == null || !await PinService.hasPin(userId)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    appLockedNotifier.value = true;
  }

  // Com o app bloqueado, o botão "voltar" não deve navegar por baixo do PIN.
  @override
  Future<bool> didPopRoute() async => appLockedNotifier.value;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: appDarkModeNotifier,
      builder: (context, isDarkMode, _) {
        return MaterialApp(
          navigatorKey: appNavigatorKey,
          theme: buildAppTheme(),
          darkTheme: buildAppDarkTheme(),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: appLockedNotifier,
              builder: (context, isLocked, _) {
                return Stack(
                  children: [
                    ExcludeSemantics(
                      excluding: isLocked,
                      child: child ?? const SizedBox.shrink(),
                    ),
                    if (isLocked) const Positioned.fill(child: PinLockScreen()),
                  ],
                );
              },
            );
          },
          home: FutureBuilder<Widget>(
            future: _initialScreen,
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
