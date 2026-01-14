import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/domain/repositories/diary_repository.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';
import 'package:musiclog/views/utils/diary_grouper.dart';
import 'package:musiclog/views/widgets/diary_detail_dialog.dart';

import '../domain/models/diary_entry.dart';
import '../domain/models/song.dart';

class DiaryListView extends StatefulWidget {
  final SongCatalogRepository songRepository;
  final DiaryRepository diaryRepository;
  const DiaryListView({
    super.key,
    required this.songRepository,
    required this.diaryRepository,
  });
  @override
  State<DiaryListView> createState() => _DiaryListViewState();
}
class _DiaryListViewState extends State<DiaryListView> {
  late Future<List<DiaryEntry>> _diaryFuture;

  @override
  void initState() {
    super.initState();
    _diaryFuture = widget.diaryRepository.listAll();
  }

  Future<Song?> _getSong(String songId) async {
    final song = await widget.songRepository.getById(songId);
    return song;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: _diaryFuture, builder: (context, snapshot) {
      if(snapshot.connectionState == ConnectionState.waiting){
        return Center(child: CircularProgressIndicator());
      }

      if(!snapshot.hasData || snapshot.data!.isEmpty){
        return Center(child: Text('No diary'));
      }

      final entries = snapshot.data!;
      final monthGroups = DiaryGrouper.groupByMonth(entries);

      return ListView.builder(
        padding: EdgeInsets.only(bottom: 16),
        itemCount: monthGroups.length,
        itemBuilder: (context, monthIndex) {
          final monthGroup = monthGroups[monthIndex];

          return ExpansionTile(
            initiallyExpanded: true,
            tilePadding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            childrenPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
            ),
            collapsedShape: RoundedRectangleBorder(
              side: BorderSide.none,
            ),

            title: Text(
              '${monthGroup.monthLabel} (${monthGroup.entries.length})',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: context.appColors.textPrimary,
              ),
            ),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: monthGroup.entries.length,
                itemBuilder: (context, entryIndex){
                  final entry = monthGroup.entries[entryIndex];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      color: context.appColors.surfaceVariant,    // ← 사용 (옅은 베이지)
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            '${entry.date.day}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: context.appColors.primary,  // ← 사용 (파스텔 블루)
                        ),
                        title: Text(
                          entry.content.length > 30
                              ? '${entry.content.substring(0, 30)}...'
                              : entry.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.appColors.textPrimary,
                          ),
                        ),
                        subtitle: entry.recommendation != null
                            ? FutureBuilder<Song?>(
                          future: _getSong(entry.recommendation!.songId),
                          builder: (context, songSnapshot){
                            if(songSnapshot.connectionState == ConnectionState.waiting){
                              return Text(
                                'Loading Songs...',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.appColors.textSecondary,
                                ),
                              );
                            }
                            if(songSnapshot.hasData && songSnapshot.data != null){
                              final song = songSnapshot.data!;
                              return Text(
                                '🎵 ${song.title} - ${song.artist}',
                                maxLines: 1,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: context.appColors.textSecondary,
                                ),
                              );
                            }
                            return Text(
                              'Unable to find Songs',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: context.appColors.error,
                              ),
                            );
                          },
                        )
                            : Text(
                          '${entry.date.year} - ${entry.date.month.toString().padLeft(2, '0')} - ${entry.date.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.appColors.textSecondary,
                          ),
                        ),
                        trailing: entry.recommendation != null
                            ? Icon(
                          Icons.music_note_rounded,
                          color: context.appColors.primary,              // ← 사용
                          size: 24,
                        )
                            : null,
                        onTap: () {
                          showDialog(context: context,
                              builder: (context) => DiaryDetailDialog(diaryEntry: entry, songRepository: widget.songRepository)
                          );
                        },
                      ),
                    ),
                  );
                },
              )
            ],
          );
        },
      );
    });
  }
}
