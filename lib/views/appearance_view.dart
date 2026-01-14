import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/config/app_theme_controller.dart';

class AppearanceView extends StatefulWidget {
  final AppThemeController controller;

  const AppearanceView({super.key, required this.controller});

  @override
  State<AppearanceView> createState() => _AppearanceViewState();
}

class _AppearanceViewState extends State<AppearanceView> {
  double? _previewScale; // 슬라이더 드래그 중 미리보기용

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeState>(
      valueListenable: widget.controller.notifier,
      builder: (context, state, _) {
        final isDark = state.themeMode == ThemeMode.dark;
        final previewScale = _previewScale ?? state.textScale;

        return Scaffold(
          backgroundColor: context.appColors.background,
          appBar: AppBar(
            backgroundColor: context.appColors.background,
            foregroundColor: context.appColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: context.appColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
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
                          onTap: () => widget.controller.setThemeMode(ThemeMode.light),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ToggleButton(
                          text: 'Dark',
                          selected: isDark,
                          onTap: () => widget.controller.setThemeMode(ThemeMode.dark),
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
                      widget.controller.setFontFamily(v);
                    },
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.appColors.textPrimary,
                    ),
                    dropdownColor: context.appColors.surface,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.appColors.surfaceVariant,
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
                      // 미리보기 텍스트 (드래그 중에도 즉시 반영)
                      MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          textScaler: TextScaler.linear(previewScale),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: context.appColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: context.appColors.border),
                          ),
                          child: Text(
                            'Preview: 오늘의 기록이 쌓여요 🎵',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: context.appColors.textPrimary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Slider(
                        value: previewScale,
                        min: 0.85,
                        max: 1.25,
                        onChanged: (v) {
                          setState(() => _previewScale = v);
                        },
                        onChangeEnd: (v) async {
                          setState(() => _previewScale = null);
                          await widget.controller.setTextScale(v);
                        },
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Small', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary)),
                          Text(previewScale.toStringAsFixed(2),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: context.appColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              )),
                          Text('Large', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.appColors.textSecondary)),
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
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withOpacity(0.06),
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: context.appColors.textPrimary,
              fontWeight: FontWeight.bold,
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
          color: selected ? context.appColors.primary.withOpacity(0.18) : context.appColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? context.appColors.primary : context.appColors.border,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: selected ? context.appColors.primary : context.appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}