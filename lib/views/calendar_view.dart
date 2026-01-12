import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:collection/collection.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/domain/repositories/diary_repository.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';
import '../domain/models/diary_entry.dart';
import '../domain/models/song.dart';

class CalendarView extends StatefulWidget {
  final DiaryRepository diaryRepository;
  final SongCatalogRepository songRepository;

  const CalendarView({
    super.key,
    required this.diaryRepository,
    required this.songRepository,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late Future<List<DiaryEntry>> _diaryFuture;
  DateTime _focusedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  @override
  void initState() {
    super.initState();
    _diaryFuture = widget.diaryRepository.listAll();
    _focusedDay = DateTime(_today.year, _today.month, 1);
  }

  Future<String?> _getSongImageUrl(String? songId) async {
    if (songId == null) return null;
    final song = await widget.songRepository.getById(songId);
    return song?.coverUrl;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);

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
                      '${_focusedDay.year}',
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        height: 1.2,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nanum',
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('MMMM').format(_focusedDay),
                      maxLines: 1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        height: 0.9,
                        fontSize: 50,
                        fontWeight: FontWeight.normal,
                        fontFamily: 'Nanum',
                        color: AppColors.textPrimary,
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
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No diary entries'));
                }

                final entries = snapshot.data!;

                return TableCalendar(
                  key: ValueKey(_focusedDay),
                  focusedDay: _focusedDay,
                  firstDay: DateTime(2020),
                  lastDay: _today,
                  headerVisible: false,
                  onPageChanged: (focusedDay){
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
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

                      return Center(
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Nanum",
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      // 해당 날짜의 일기 찾기
                      final diaryEntry = entries.firstWhereOrNull(
                            (entry) =>
                        entry.date.year == day.year &&
                            entry.date.month == day.month &&
                            entry.date.day == day.day,
                      );

                      if (diaryEntry != null) {
                        return Center(
                          child: ClipOval(
                            child: FutureBuilder<String?>(
                              future: _getSongImageUrl(diaryEntry.recommendation?.songId),
                              builder: (context, imageSnapshot) {
                                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.primary,
                                    ),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final imageUrl = imageSnapshot.data;
                                if (imageUrl != null) {
                                  return Image.network(
                                    imageUrl,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${day.day}',
                                            style: TextStyle(
                                              fontFamily: "Nanum",
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }

                                // 노래 없으면 숫자 표시
                                return Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primary,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontFamily: "Nanum",
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

                      return null;
                    },
                  ),
                  enabledDayPredicate: (day){
                    return !day.isAfter(_today);
                  },
                  calendarStyle: CalendarStyle(
                    disabledTextStyle: TextStyle(
                      color: AppColors.textHint,
                      fontFamily: "Nanum",
                      fontSize: 20,
                    ),
                    defaultTextStyle: TextStyle(
                      fontFamily: "Nanum",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    weekendTextStyle: TextStyle(
                      fontFamily: "Nanum",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    selectedTextStyle: TextStyle(
                      fontFamily: "Nanum",
                      color: AppColors.primary,
                    ),
                    todayTextStyle: TextStyle(
                      fontFamily: "Nanum",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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
