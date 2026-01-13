import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';

class SettingsView extends StatelessWidget {
  final VoidCallback onExportMarkdown;
  final VoidCallback onExportJson;
  final VoidCallback onOpenStats;
  final VoidCallback onOpenAppearance;
  final VoidCallback onClearDrafts;
  final VoidCallback onClearUsedSongs;

  const SettingsView({
    super.key,
    required this.onExportMarkdown,
    required this.onExportJson,
    required this.onOpenStats,
    required this.onOpenAppearance,
    required this.onClearDrafts,
    required this.onClearUsedSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontFamily: 'Nanum',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final crossAxisCount = w >= 900 ? 4 : (w >= 600 ? 3 : 2);
                final childAspectRatio = w >= 600 ? 1.25 : 1.05;

                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: childAspectRatio,
                  children: [
                    _ActionCard(
                      title: 'Export Markdown',
                      subtitle: 'Save diaries as .md files',
                      icon: Icons.description_outlined,
                      onTap: onExportMarkdown,
                    ),
                    _ActionCard(
                      title: 'Export JSON',
                      subtitle: 'Save structured data',
                      icon: Icons.data_object_outlined,
                      onTap: onExportJson,
                    ),
                    _ActionCard(
                      title: 'Insights',
                      subtitle: 'Writing stats and trends',
                      icon: Icons.insights_outlined,
                      onTap: onOpenStats,
                    ),
                    _ActionCard(
                      title: 'Appearance',
                      subtitle: 'Theme and font',
                      icon: Icons.palette_outlined,
                      onTap: onOpenAppearance,
                    ),
                    _ActionCard(
                      title: 'Clear Drafts',
                      subtitle: 'Remove saved drafts',
                      icon: Icons.delete_sweep_outlined,
                      onTap: onClearDrafts,
                      danger: true,
                    ),
                    _ActionCard(
                      title: 'Reset Used Songs',
                      subtitle: 'Allow repeats again',
                      icon: Icons.restart_alt_outlined,
                      onTap: onClearUsedSongs,
                      danger: true,
                    ),
                    _ActionCard.disabled(
                      title: 'Apple Music Playlist',
                      subtitle: 'Coming soon',
                      icon: Icons.queue_music_outlined,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;
  final bool danger;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.disabled = false,
    this.danger = false,
  });

  const _ActionCard.disabled({
    required this.title,
    required this.subtitle,
    required this.icon,
  })  : onTap = null,
        disabled = true,
        danger = false;

  @override
  Widget build(BuildContext context) {
    final baseColor = disabled
        ? AppColors.surfaceVariant
        : (danger ? AppColors.error.withOpacity(0.08) : AppColors.surface);

    final borderColor = disabled
        ? AppColors.border.withOpacity(0.6)
        : (danger ? AppColors.error.withOpacity(0.35) : AppColors.border);

    final titleColor = disabled
        ? AppColors.textSecondary.withOpacity(0.7)
        : (danger ? AppColors.error : AppColors.textPrimary);

    final subtitleColor = disabled
        ? AppColors.textSecondary.withOpacity(0.55)
        : AppColors.textSecondary;

    final iconColor = disabled
        ? AppColors.textSecondary.withOpacity(0.55)
        : (danger ? AppColors.error : AppColors.primary);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
          boxShadow: disabled
              ? null
              : [
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
            Icon(icon, size: 28, color: iconColor),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Nanum',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Nanum',
                fontSize: 13,
                height: 1.25,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}