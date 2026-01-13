import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/config/app_theme_controller.dart';

class AppearanceView extends StatelessWidget {
  final AppThemeController controller;

  const AppearanceView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeState>(
      valueListenable: controller.notifier,
      builder: (context, state, _) {
        final isDark = state.themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              'Appearance',
              style: TextStyle(
                fontFamily: state.fontFamily,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                _Card(
                  title: 'Theme',
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToggleButton(
                          text: 'Light',
                          selected: !isDark,
                          onTap: () => controller.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ToggleButton(
                          text: 'Dark',
                          selected: isDark,
                          onTap: () => controller.setThemeMode(ThemeMode.dark),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Card(
                  title: 'Font',
                  child: DropdownButtonFormField<String>(
                    value: state.fontFamily,
                    items: const [
                      DropdownMenuItem(value: 'Nanum', child: Text('Nanum')),
                      DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      controller.setFontFamily(v);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _Card(
                  title: 'Text Size',
                  child: Column(
                    children: [
                      Slider(
                        value: state.textScale,
                        min: 0.85,
                        max: 1.25,
                        onChanged: (v) => controller.setTextScale(v),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Small',
                            style: TextStyle(
                              fontFamily: state.fontFamily,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            state.textScale.toStringAsFixed(2),
                            style: TextStyle(
                              fontFamily: state.fontFamily,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Large',
                            style: TextStyle(
                              fontFamily: state.fontFamily,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final Widget child;

  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Nanum',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.18) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Nanum',
            fontWeight: FontWeight.bold,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}