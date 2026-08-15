import 'package:flutter/material.dart';

@immutable
class AudioThemeTokens extends ThemeExtension<AudioThemeTokens> {
  final Color background;
  final Color surface;
  final Color surfaceRaised;
  final Color border;
  final Color accent;
  final Color accentSoft;
  final Color signal;
  final Color warning;
  final Color mutedText;

  const AudioThemeTokens({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.border,
    required this.accent,
    required this.accentSoft,
    required this.signal,
    required this.warning,
    required this.mutedText,
  });

  @override
  AudioThemeTokens copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? border,
    Color? accent,
    Color? accentSoft,
    Color? signal,
    Color? warning,
    Color? mutedText,
  }) {
    return AudioThemeTokens(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      signal: signal ?? this.signal,
      warning: warning ?? this.warning,
      mutedText: mutedText ?? this.mutedText,
    );
  }

  @override
  AudioThemeTokens lerp(ThemeExtension<AudioThemeTokens>? other, double t) {
    if (other is! AudioThemeTokens) return this;

    return AudioThemeTokens(
      background: Color.lerp(background, other.background, t) ?? background,
      surface: Color.lerp(surface, other.surface, t) ?? surface,
      surfaceRaised:
          Color.lerp(surfaceRaised, other.surfaceRaised, t) ?? surfaceRaised,
      border: Color.lerp(border, other.border, t) ?? border,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t) ?? accentSoft,
      signal: Color.lerp(signal, other.signal, t) ?? signal,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      mutedText: Color.lerp(mutedText, other.mutedText, t) ?? mutedText,
    );
  }
}

ThemeData buildAudioAppTheme() {
  const background = Color(0xFF0F1726);
  const surface = Color(0xFF151E2E);
  const surfaceRaised = Color(0xFF1B2638);
  const border = Color(0xFF2F3E57);
  const accent = Color(0xFF6F8CFF);
  const accentSoft = Color(0xFF22314A);
  const signal = Color(0xFF4EC7A3);
  const warning = Color(0xFFE3B35A);
  const mutedText = Color(0xFFA7B5CC);

  const colorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: accent,
    onPrimary: Colors.white,
    secondary: signal,
    onSecondary: background,
    surface: surface,
    onSurface: Colors.white,
    error: Color(0xFFFF7B72),
    onError: Colors.white,
  );

  final baseTextTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
  ).textTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    textTheme: baseTextTheme.copyWith(
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -0.9,
      ),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -0.5,
      ),
      titleLarge: baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      titleMedium: baseTextTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(
        height: 1.55,
        color: Colors.white,
      ),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(
        height: 1.5,
        color: mutedText,
      ),
      labelLarge: baseTextTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceRaised.withValues(alpha: 0.72),
      labelStyle: const TextStyle(color: mutedText),
      hintStyle: const TextStyle(color: mutedText),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: accent, width: 1.4),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        foregroundColor: Colors.white,
        side: const BorderSide(color: border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    extensions: const [
      AudioThemeTokens(
        background: background,
        surface: surface,
        surfaceRaised: surfaceRaised,
        border: border,
        accent: accent,
        accentSoft: accentSoft,
        signal: signal,
        warning: warning,
        mutedText: mutedText,
      ),
    ],
  );
}

extension AudioThemeContextX on BuildContext {
  AudioThemeTokens get audioTheme =>
      Theme.of(this).extension<AudioThemeTokens>()!;

  bool get isCompactLayout => MediaQuery.sizeOf(this).width < 720;

  bool get isMediumLayout {
    final width = MediaQuery.sizeOf(this).width;
    return width >= 720 && width < 1120;
  }

  Duration get motionDuration {
    final mediaQuery = MediaQuery.maybeOf(this);
    if (mediaQuery?.disableAnimations ?? false) {
      return Duration.zero;
    }

    return const Duration(milliseconds: 260);
  }

  EdgeInsets get pagePadding {
    final width = MediaQuery.sizeOf(this).width;
    if (width < 720) return const EdgeInsets.all(16);
    if (width < 1120) return const EdgeInsets.all(24);
    return const EdgeInsets.all(32);
  }

  BoxDecoration buildPanelDecoration({
    Gradient? gradient,
    Color? color,
    bool emphasize = false,
  }) {
    return BoxDecoration(
      color: color ?? audioTheme.surface,
      gradient: gradient,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(
        color: emphasize
            ? audioTheme.accent.withValues(alpha: 0.5)
            : audioTheme.border,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: emphasize ? 0.18 : 0.1),
          blurRadius: emphasize ? 18 : 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
