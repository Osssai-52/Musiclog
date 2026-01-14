import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeState {
  final ThemeMode themeMode;
  final double textScale;
  final String fontFamily;

  const AppThemeState({
    required this.themeMode,
    required this.textScale,
    required this.fontFamily,
  });

  AppThemeState copyWith({
    ThemeMode? themeMode,
    double? textScale,
    String? fontFamily,
  }) {
    return AppThemeState(
      themeMode: themeMode ?? this.themeMode,
      textScale: textScale ?? this.textScale,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class AppThemeController {
  static const _kThemeMode = 'app_theme_mode';
  static const _kTextScale = 'app_text_scale';
  static const _kFontFamily = 'app_font_family';

  final ValueNotifier<AppThemeState> notifier = ValueNotifier(
    const AppThemeState(
      themeMode: ThemeMode.light,
      textScale: 1.0,
      fontFamily: 'Nanum',
    ),
  );

  AppThemeState get state => notifier.value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final rawMode = prefs.getString(_kThemeMode) ?? 'light';
    final mode = rawMode == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final scale = (prefs.getDouble(_kTextScale) ?? 1.0).clamp(0.85, 1.25);
    final font = prefs.getString(_kFontFamily) ?? 'Nanum';

    notifier.value = AppThemeState(themeMode: mode, textScale: scale, fontFamily: font);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeMode, mode == ThemeMode.dark ? 'dark' : 'light');
    notifier.value = notifier.value.copyWith(themeMode: mode);
  }

  Future<void> setTextScale(double scale) async {
    final v = scale.clamp(0.85, 1.25);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScale, v);
    notifier.value = notifier.value.copyWith(textScale: v);
  }

  Future<void> setFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamily, fontFamily);
    notifier.value = notifier.value.copyWith(fontFamily: fontFamily);
  }

}