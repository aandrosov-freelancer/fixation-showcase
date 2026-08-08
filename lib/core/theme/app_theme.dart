import 'package:app/core/values/colors.gen.dart';
import 'package:flutter/material.dart';
import 'package:go_transitions/go_transitions.dart';

class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color containerFill;
  final Color textMuted;
  final List<Color> editorPalette;

  const AppCustomColors({
    required this.containerFill,
    required this.textMuted,
    required this.editorPalette,
  });

  @override
  AppCustomColors copyWith({
    Color? containerFill,
    Color? textMuted,
    List<Color>? editorPalette,
  }) {
    return AppCustomColors(
      containerFill: containerFill ?? this.containerFill,
      textMuted: textMuted ?? this.textMuted,
      editorPalette: editorPalette ?? this.editorPalette,
    );
  }

  @override
  AppCustomColors lerp(ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) return this;
    return AppCustomColors(
      containerFill: Color.lerp(containerFill, other.containerFill, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      editorPalette: editorPalette,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppCustomColors get customColors =>
      Theme.of(this).extension<AppCustomColors>() ?? AppTheme.lightCustomColors;
}

class AppTheme {
  static const AppCustomColors lightCustomColors = AppCustomColors(
    containerFill: ColorName.containerFill,
    textMuted: ColorName.textMuted,
    editorPalette: [
      ColorName.paletteBlack,
      ColorName.paletteRose,
      ColorName.paletteAmber,
      ColorName.paletteGreen,
      ColorName.paletteBlue,
      ColorName.palettePurple,
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: GoTransitions.zoom,
          TargetPlatform.iOS: GoTransitions.zoom,
        },
      ),
      scaffoldBackgroundColor: ColorName.background,
      colorScheme: const ColorScheme.light(
        primary: ColorName.primary,
        onPrimary: ColorName.white,
        surface: ColorName.card,
        onSurface: ColorName.textPrimary,
        outline: ColorName.border,
        outlineVariant: ColorName.divider,
        secondary: ColorName.textSecondary,
        error: ColorName.destructive,
      ),
      extensions: const [lightCustomColors],
      appBarTheme: const AppBarTheme(
        backgroundColor: ColorName.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ColorName.textPrimary),
        titleTextStyle: TextStyle(
          color: ColorName.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: ColorName.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: ColorName.border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ColorName.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorName.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorName.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ColorName.primary, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: ColorName.primary,
        foregroundColor: ColorName.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(200),
          ),
        ),
      ),
    );
  }
}
