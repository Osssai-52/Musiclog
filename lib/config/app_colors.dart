import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  // Primary
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;

  // Secondary
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;

  // Accent
  final Color accent;

  // Background & Surface
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Status
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  // Utility
  final Color border;
  final Color divider;
  final Color shadow;

  // Icon
  final Color musicIcon;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.accent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.border,
    required this.divider,
    required this.shadow,
    required this.musicIcon,
  });

  /// ✅ 기존(라이트) 팔레트 = 네가 주던 값 그대로
  static const light = AppColors(
    primary: Color(0xff7BA3D0),
    primaryLight: Color(0xff9DBDE8),
    primaryDark: Color(0xff5B7FA8),

    secondary: Color(0xffE8B4A0),
    secondaryLight: Color(0xffF0D4C4),
    secondaryDark: Color(0xffD89880),

    accent: Color(0xffB8D4C8),

    background: Color(0xFFFAF7F2),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xffF5F0EB),

    textPrimary: Color(0xff4A5568),
    textSecondary: Color(0xff718096),
    textHint: Color(0xffCBD5E1),

    success: Color(0xffA8D5BA),
    warning: Color(0xffF4D89F),
    error: Color(0xffE8A5A0),
    info: Color(0xff7BA3D0),

    border: Color(0xffE8DDD5),
    divider: Color(0xffF0E8E0),
    shadow: Color(0xff000000),

    musicIcon: Color(0xff7BA3D0),
  );

  static const dark = AppColors(
    primary: Color(0xff7BA3D0),
    primaryLight: Color(0xff9DBDE8),
    primaryDark: Color(0xff5B7FA8),

    secondary: Color(0xffE8B4A0),
    secondaryLight: Color(0xffF0D4C4),
    secondaryDark: Color(0xffD89880),

    accent: Color(0xff8FBFB0),

    background: Color(0xFF0F1115),
    surface: Color(0xFF171A21),
    surfaceVariant: Color(0xFF1F2430),

    textPrimary: Color(0xFFE6E8EE),
    textSecondary: Color(0xFFB3B9C6),
    textHint: Color(0xFF6B7280),

    success: Color(0xFF7FC89B),
    warning: Color(0xFFF2C97D),
    error: Color(0xFFF19992),
    info: Color(0xff7BA3D0),

    border: Color(0xFF2A2F3A),
    divider: Color(0xFF222733),
    shadow: Color(0xff000000),

    musicIcon: Color(0xff7BA3D0),
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryDark,
    Color? accent,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? border,
    Color? divider,
    Color? shadow,
    Color? musicIcon,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      accent: accent ?? this.accent,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      musicIcon: musicIcon ?? this.musicIcon,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color lc(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return AppColors(
      primary: lc(primary, other.primary),
      primaryLight: lc(primaryLight, other.primaryLight),
      primaryDark: lc(primaryDark, other.primaryDark),
      secondary: lc(secondary, other.secondary),
      secondaryLight: lc(secondaryLight, other.secondaryLight),
      secondaryDark: lc(secondaryDark, other.secondaryDark),
      accent: lc(accent, other.accent),
      background: lc(background, other.background),
      surface: lc(surface, other.surface),
      surfaceVariant: lc(surfaceVariant, other.surfaceVariant),
      textPrimary: lc(textPrimary, other.textPrimary),
      textSecondary: lc(textSecondary, other.textSecondary),
      textHint: lc(textHint, other.textHint),
      success: lc(success, other.success),
      warning: lc(warning, other.warning),
      error: lc(error, other.error),
      info: lc(info, other.info),
      border: lc(border, other.border),
      divider: lc(divider, other.divider),
      shadow: lc(shadow, other.shadow),
      musicIcon: lc(musicIcon, other.musicIcon),
    );
  }
}

extension AppColorsX on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>() ?? AppColors.light;
}