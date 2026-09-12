import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF2D5FD3);
  static const primaryDark = Color(0xFF203A8F);
  static const primarySoft = Color(0xFFEFF4FF);
  static const primaryBorder = Color(0xFFB9CCFF);
  static const chipText = Color(0xFF2D4FAD);

  static const textMuted = Color(0xFF42507B);
  static const textFaint = Color(0xFF6D7B9F);

  static const cardBorder = Color(0xFFDCE6FF);
  static const inputFill = Color(0xFFF9FBFF);

  static const backgroundStart = Color(0xFFF4F8FF);
  static const backgroundEnd = Color(0xFFE7EEFF);

  static const success = Color(0xFF2ABE6B);
  static const successSoft = Color(0xFF7BDCA6);
  static const danger = Color(0xFFFF7171);
  static const dangerSoft = Color(0xFFFFAFAF);
  static const accentBlue = Color(0xFF7194FF);

  // Variantes para o tema escuro.
  static const backgroundStartDark = Color(0xFF0F1420);
  static const backgroundEndDark = Color(0xFF161D2E);
  static const cardDark = Color(0xFF1B2233);
  static const cardBorderDark = Color(0xFF2A3350);
  static const inputFillDark = Color(0xFF232C42);
  static const textMutedDark = Color(0xFFAEB9DD);
  static const textFaintDark = Color(0xFF8892B0);
}

class AppGradients {
  AppGradients._();

  static const background = LinearGradient(
    colors: [AppColors.backgroundStart, AppColors.backgroundEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const backgroundDark = LinearGradient(
    colors: [AppColors.backgroundStartDark, AppColors.backgroundEndDark],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const primary = LinearGradient(
    colors: [AppColors.primary, AppColors.accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const success = LinearGradient(
    colors: [AppColors.success, AppColors.successSoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const danger = LinearGradient(
    colors: [AppColors.danger, AppColors.dangerSoft],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppGradients.backgroundDark : AppGradients.background,
      ),
      child: child,
    );
  }
}

const _headingStyle = TextStyle(
  fontFamily: 'JetBrains Mono',
  fontWeight: FontWeight.bold,
  color: AppColors.primaryDark,
);

const _headingStyleDark = TextStyle(
  fontFamily: 'JetBrains Mono',
  fontWeight: FontWeight.bold,
  color: AppColors.accentBlue,
);

ThemeData buildAppTheme() {
  final base = ThemeData(useMaterial3: true);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.backgroundStart,
    textTheme: base.textTheme.copyWith(
      headlineSmall: _headingStyle.copyWith(fontSize: 24),
      titleLarge: _headingStyle.copyWith(fontSize: 20),
      titleMedium: _headingStyle.copyWith(fontSize: 18),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primaryBorder),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.primary),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? AppColors.primary : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary.withValues(alpha: 0.5)
            : null,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFF9AA6C7),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.cardBorder,
      space: 24,
      thickness: 1,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.primary,
      textColor: AppColors.textMuted,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}

ThemeData buildAppDarkTheme() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.dark);

  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundStartDark,
    textTheme: base.textTheme.copyWith(
      headlineSmall: _headingStyleDark.copyWith(fontSize: 24),
      titleLarge: _headingStyleDark.copyWith(fontSize: 20),
      titleMedium: _headingStyleDark.copyWith(fontSize: 18),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontWeight: FontWeight.bold,
        fontSize: 22,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.cardDark,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.cardBorderDark),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFillDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accentBlue,
        side: const BorderSide(color: AppColors.cardBorderDark),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accentBlue),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) =>
            states.contains(WidgetState.selected) ? AppColors.primary : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.primary.withValues(alpha: 0.5)
            : null,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardDark,
      selectedItemColor: AppColors.accentBlue,
      unselectedItemColor: Color(0xFF5C6690),
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      elevation: 8,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.cardBorderDark,
      space: 24,
      thickness: 1,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.accentBlue,
      textColor: AppColors.textMutedDark,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );
}
