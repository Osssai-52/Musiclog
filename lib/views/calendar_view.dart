import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:musiclog/views/widgets/diary_detail_dialog.dart';
import 'package:musiclog/views/widgets/diary_edit_dialog.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/domain/repositories/diary_repository.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';
import '../domain/models/diary_entry.dart';
import 'package:musiclog/di/app_dependencies.dart';

class CalendarView extends StatefulWidget {
  final DiaryRepository diaryRepository;
  final SongCatalogRepository songRepository;
  final AppDependencies dependencies;

  const CalendarView({
    super.key,
    required this.diaryRepository,
    required this.songRepository,
    required this.dependencies
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late Future<List<DiaryEntry>> _diaryFuture;
  DateTime _focusedDayUtc = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    1,
  );

  @override
  void initState() {
    super.initState();
    _diaryFuture = widget.diaryRepository.listAll();
  }

  int _dayKeyLocal(DateTime d) {
    final x = d.toLocal();
    return x.year * 10000 + x.month * 100 + x.day;
  }

  DiaryEntry? _entryForDay(List<DiaryEntry> entries, DateTime dayFromCalendar) {
    final target = _dayKeyLocal(dayFromCalendar);
    return entries.firstWhereOrNull((e) => _dayKeyLocal(e.date) == target);
  }

  Future<String?> _getSongImageUrl(String? songId) async {
    if (songId == null) return null;
    final song = await widget.songRepository.getById(songId);
    return song?.coverUrl;
  }

  Widget _buildSongDay(DateTime day, DiaryEntry diaryEntry) {
    return Center(
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => DiaryDetailDialog(
              diaryEntry: diaryEntry,
              songRepository: widget.songRepository,
            ),
          );
        },
        child: FutureBuilder<String?>(
          future: _getSongImageUrl(
            diaryEntry.recommendation?.songId ?? diaryEntry.recommendedSongId,
          ),
          builder: (context, imageSnapshot) {
            if (imageSnapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.primary,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              );
            }

            final imageUrl = imageSnapshot.data;
            if (imageUrl != null) {
              return ClipOval(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: OverflowBox(
                    alignment: Alignment.center,
                    maxWidth: 42,
                    maxHeight: 42,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.appColors.primary,
                          ),
                          child: Center(
                            child: Text(
                              '${day.day}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }

            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appColors.primary,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditDay(DateTime day) {
    return Center(
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.appColors.primary.withOpacity(0.4),
          border: Border.all(color: context.appColors.primary, width: 2),
        ),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyDay(DateTime day) {
    return Center(
      child: Text(
        '${day.day}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _openDetail(DiaryEntry diaryEntry) async {
    await showDialog(
      context: context,
      builder: (context) => DiaryDetailDialog(
        diaryEntry: diaryEntry,
        songRepository: widget.songRepository,
      ),
    );
  }

  Future<void> _openEdit(DateTime calendarDay) async {
    final localDay = DateTime(
      calendarDay.toLocal().year,
      calendarDay.toLocal().month,
      calendarDay.toLocal().day,
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => DiaryEditDialog(
        diaryRepository: widget.diaryRepository,
        songRepository: widget.songRepository,
        recommendSongUseCase: widget.dependencies.recommendSongUseCase,
        selectedDate: localDay,
      ),
    );

    if (result == 'refresh') {
      setState(() {
        _diaryFuture = widget.diaryRepository.listAll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayKey = now.year * 10000 + now.month * 100 + now.day;

    final firstDayUtc = DateTime.utc(2020, 1, 1);
    final lastDayUtc = DateTime.utc(now.year, now.month, now.day);
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_focusedDayUtc.toLocal().year}',
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.2,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM').format(_focusedDayUtc.toLocal()),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 0.9,
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: context.appColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DiaryEntry>>(
              future: _diaryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entries = snapshot.data ?? <DiaryEntry>[];

                Widget buildCell(DateTime day) {
                  final diaryEntry = _entryForDay(entries, day);
                  final isToday = _dayKeyLocal(day) == todayKey;

                  if (diaryEntry != null) {
                    return _buildSongDay(day, diaryEntry);
                  }

                  if (isToday) {
                    return _buildEditDay(day);
                  }

                  return _buildEmptyDay(day);
                }

                return TableCalendar(
                  firstDay: firstDayUtc,
                  lastDay: lastDayUtc,
                  focusedDay: _focusedDayUtc,
                  headerVisible: false,
                  selectedDayPredicate: (_) => false,
                  enabledDayPredicate: (day) {
                    return _dayKeyLocal(day) <= todayKey;
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDayUtc = focusedDay;
                    });
                  },
                  onDaySelected: (selectedDay, focusedDay) async {
                    final selectedKey = _dayKeyLocal(selectedDay);
                    if (selectedKey > todayKey) return;

                    final diaryEntry = _entryForDay(entries, selectedDay);
                    final isToday = selectedKey == todayKey;

                    if (diaryEntry != null) {
                      await _openDetail(diaryEntry);
                      return;
                    }

                    if (isToday) {
                      await _openEdit(selectedDay);
                      return;
                    }
                  },
                  daysOfWeekHeight: 28,
                  calendarBuilders: CalendarBuilders(

                    dowBuilder: (context, date) {
                      String text;
                      switch (date.weekday) {
                        case DateTime.monday:
                          text = 'M';
                          break;
                        case DateTime.tuesday:
                          text = 'T';
                          break;
                        case DateTime.wednesday:
                          text = 'W';
                          break;
                        case DateTime.thursday:
                          text = 'T';
                          break;
                        case DateTime.friday:
                          text = 'F';
                          break;
                        case DateTime.saturday:
                          text = 'S';
                          break;
                        case DateTime.sunday:
                          text = 'S';
                          break;
                        default:
                          text = DateFormat.E('en_US').format(date);
                      }

                      return Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 6),
                          child: Text(
                            text,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.appColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) => buildCell(day),
                    defaultBuilder: (context, day, focusedDay) => buildCell(day),
                  ),
                calendarStyle: CalendarStyle(
                  disabledTextStyle: (t.bodyLarge ?? const TextStyle()).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textHint,
                  ),
                  defaultTextStyle: (t.bodyLarge ?? const TextStyle()).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                  weekendTextStyle: (t.bodyLarge ?? const TextStyle()).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.textPrimary,
                  ),
                  selectedTextStyle: (t.bodyLarge ?? const TextStyle()).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.primary,
                  ),
                  todayTextStyle: (t.bodyLarge ?? const TextStyle()).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.primary,
                  ),
                  outsideDaysVisible: false,
                ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}