import 'package:flutter/material.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/domain/models/diary_entry.dart';
import 'package:musiclog/domain/models/song.dart';
import 'package:musiclog/domain/repositories/diary_repository.dart';
import 'package:musiclog/domain/repositories/song_catalog_repository.dart';

class InsightsView extends StatefulWidget {
  final DiaryRepository diaryRepository;
  final SongCatalogRepository songRepository;

  const InsightsView({
    super.key,
    required this.diaryRepository,
    required this.songRepository,
  });

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  bool _loading = true;
  String? _error;

  List<DiaryEntry> _entries = const [];
  Map<String, Song> _songById = const {};

  int _totalEntries = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;

  double _avgConfidence = 0.0;
  int _confidenceCount = 0;

  Map<String, int> _monthCounts = const {};
  Map<int, int> _weekdayCounts = const {};
  List<MapEntry<String, int>> _topSongs = const [];
  List<MapEntry<String, int>> _topArtists = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  String _ymKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final entries = await widget.diaryRepository.listAll(newestFirst: false);

      Map<String, Song> songById = {};
      try {
        final songs = await widget.songRepository.getTopSongs();
        songById = {for (final s in songs) s.id: s};
      } catch (_) {
        songById = {};
      }

      final computed = _compute(entries, songById);

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _songById = songById;

        _totalEntries = computed.totalEntries;
        _currentStreak = computed.currentStreak;
        _maxStreak = computed.maxStreak;
        _avgConfidence = computed.avgConfidence;
        _confidenceCount = computed.confidenceCount;
        _monthCounts = computed.monthCounts;
        _weekdayCounts = computed.weekdayCounts;
        _topSongs = computed.topSongs;
        _topArtists = computed.topArtists;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  _Computed _compute(List<DiaryEntry> entries, Map<String, Song> songById) {
    final totalEntries = entries.length;

    final dates = entries.map((e) => _dateOnly(e.date)).toSet().toList();
    dates.sort((a, b) => a.compareTo(b));

    int currentStreak = 0;
    int maxStreak = 0;

    if (dates.isNotEmpty) {
      int run = 1;
      maxStreak = 1;

      for (int i = 1; i < dates.length; i++) {
        final prev = dates[i - 1];
        final cur = dates[i];
        final diff = cur.difference(prev).inDays;
        if (diff == 1) {
          run += 1;
        } else if (diff == 0) {
        } else {
          if (run > maxStreak) maxStreak = run;
          run = 1;
        }
      }
      if (run > maxStreak) maxStreak = run;

      final today = _dateOnly(DateTime.now());
      final set = dates.toSet();
      DateTime cursor = today;
      while (set.contains(cursor)) {
        currentStreak += 1;
        cursor = cursor.subtract(const Duration(days: 1));
      }
    }

    double sumConf = 0.0;
    int confCount = 0;

    final monthCounts = <String, int>{};
    final weekdayCounts = <int, int>{for (int i = 1; i <= 7; i++) i: 0};
    final songCounts = <String, int>{};
    final artistCounts = <String, int>{};

    for (final e in entries) {
      final d = _dateOnly(e.date);
      final ym = _ymKey(d);
      monthCounts[ym] = (monthCounts[ym] ?? 0) + 1;

      weekdayCounts[d.weekday] = (weekdayCounts[d.weekday] ?? 0) + 1;

      final rec = e.recommendation;
      if (rec != null) {
        sumConf += rec.confidence;
        confCount += 1;

        final sid = rec.songId;
        if (sid != 'NONE') {
          songCounts[sid] = (songCounts[sid] ?? 0) + 1;
          final song = songById[sid];
          if (song != null) {
            final artist = song.artist;
            artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
          }
        }
      } else if (e.recommendedSongId != null && e.recommendedSongId != 'NONE') {
        final sid = e.recommendedSongId!;
        songCounts[sid] = (songCounts[sid] ?? 0) + 1;
        final song = songById[sid];
        if (song != null) {
          final artist = song.artist;
          artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
        }
      }
    }

    final avgConf = confCount == 0 ? 0.0 : (sumConf / confCount);

    final topSongs = songCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topArtists = artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final normalizedMonthCounts = _lastMonths(monthCounts, months: 6);

    return _Computed(
      totalEntries: totalEntries,
      currentStreak: currentStreak,
      maxStreak: maxStreak,
      avgConfidence: avgConf,
      confidenceCount: confCount,
      monthCounts: normalizedMonthCounts,
      weekdayCounts: weekdayCounts,
      topSongs: topSongs.take(5).toList(),
      topArtists: topArtists.take(5).toList(),
    );
  }

  Map<String, int> _lastMonths(Map<String, int> monthCounts, {required int months}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);

    final keys = <String>[];
    DateTime cursor = start;
    for (int i = 0; i < months; i++) {
      final k = _ymKey(cursor);
      keys.add(k);
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }
    keys.reverse();

    final res = <String, int>{};
    for (final k in keys) {
      res[k] = monthCounts[k] ?? 0;
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Insights',
            style: TextStyle(
              fontFamily: 'Nanum',
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            'Insights',
            style: TextStyle(
              fontFamily: 'Nanum',
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Text(
            _error!,
            style: TextStyle(
              fontFamily: 'Nanum',
              color: AppColors.textPrimary,
            ),
          ),
        ),
      );
    }

    final monthBars = _monthCounts.entries.toList();
    final weekdayBars = [
      MapEntry('M', _weekdayCounts[DateTime.monday] ?? 0),
      MapEntry('T', _weekdayCounts[DateTime.tuesday] ?? 0),
      MapEntry('W', _weekdayCounts[DateTime.wednesday] ?? 0),
      MapEntry('T', _weekdayCounts[DateTime.thursday] ?? 0),
      MapEntry('F', _weekdayCounts[DateTime.friday] ?? 0),
      MapEntry('S', _weekdayCounts[DateTime.saturday] ?? 0),
      MapEntry('S', _weekdayCounts[DateTime.sunday] ?? 0),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Insights',
          style: TextStyle(
            fontFamily: 'Nanum',
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _StatsGrid(
                totalEntries: _totalEntries,
                currentStreak: _currentStreak,
                maxStreak: _maxStreak,
                avgConfidence: _avgConfidence,
                confidenceCount: _confidenceCount,
              ),
              const SizedBox(height: 14),
              _ChartCard(
                title: 'Last 6 Months',
                subtitle: 'Entries per month',
                child: _BarChart(
                  bars: monthBars
                      .map((e) => _Bar(
                    label: e.key.substring(5),
                    value: e.value.toDouble(),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              _ChartCard(
                title: 'Weekdays',
                subtitle: 'Entries per weekday',
                child: _BarChart(
                  bars: weekdayBars
                      .map((e) => _Bar(label: e.key, value: e.value.toDouble()))
                      .toList(),
                ),
              ),
              const SizedBox(height: 14),
              _ChartCard(
                title: 'Top Songs',
                subtitle: 'Most recommended',
                child: _RankList(
                  items: _topSongs.map((e) {
                    final song = _songById[e.key];
                    final label = song == null
                        ? e.key
                        : '${song.title} · ${song.artist}';
                    return MapEntry(label, e.value);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              _ChartCard(
                title: 'Top Artists',
                subtitle: 'Most recommended',
                child: _RankList(
                  items: _topArtists,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Computed {
  final int totalEntries;
  final int currentStreak;
  final int maxStreak;
  final double avgConfidence;
  final int confidenceCount;
  final Map<String, int> monthCounts;
  final Map<int, int> weekdayCounts;
  final List<MapEntry<String, int>> topSongs;
  final List<MapEntry<String, int>> topArtists;

  _Computed({
    required this.totalEntries,
    required this.currentStreak,
    required this.maxStreak,
    required this.avgConfidence,
    required this.confidenceCount,
    required this.monthCounts,
    required this.weekdayCounts,
    required this.topSongs,
    required this.topArtists,
  });
}

class _StatsGrid extends StatelessWidget {
  final int totalEntries;
  final int currentStreak;
  final int maxStreak;
  final double avgConfidence;
  final int confidenceCount;

  const _StatsGrid({
    required this.totalEntries,
    required this.currentStreak,
    required this.maxStreak,
    required this.avgConfidence,
    required this.confidenceCount,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final crossAxisCount = w >= 900 ? 4 : (w >= 600 ? 3 : 2);

        final cards = <Widget>[
          _MetricCard(
            title: 'Total',
            value: '$totalEntries',
            icon: Icons.library_books_outlined,
          ),
          _MetricCard(
            title: 'Streak',
            value: '$currentStreak',
            icon: Icons.local_fire_department_outlined,
          ),
          _MetricCard(
            title: 'Max Streak',
            value: '$maxStreak',
            icon: Icons.emoji_events_outlined,
          ),
          _MetricCard(
            title: 'Confidence',
            value: confidenceCount == 0 ? '-' : avgConfidence.toStringAsFixed(2),
            icon: Icons.psychology_outlined,
            subtitle: confidenceCount == 0 ? 'no data' : '$confidenceCount recs',
          ),
        ];

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: w >= 600 ? 1.7 : 1.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cards,
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nanum',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Nanum',
                    fontSize: 22,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Nanum',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Nanum',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Bar {
  final String label;
  final double value;

  _Bar({required this.label, required this.value});
}

class _BarChart extends StatelessWidget {
  final List<_Bar> bars;

  const _BarChart({required this.bars});

  @override
  Widget build(BuildContext context) {
    final maxV = bars.isEmpty
        ? 1.0
        : bars.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1.0 : maxV;

    return SizedBox(
      height: 140,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars.map((b) {
          final h = (b.value / safeMax).clamp(0.0, 1.0);
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: h,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    b.label,
                    style: TextStyle(
                      fontFamily: 'Nanum',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RankList extends StatelessWidget {
  final List<MapEntry<String, int>> items;

  const _RankList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        'No data',
        style: TextStyle(
          fontFamily: 'Nanum',
          color: AppColors.textSecondary,
        ),
      );
    }

    final maxV = items.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final safeMax = maxV <= 0 ? 1 : maxV;

    return Column(
      children: items.asMap().entries.map((entry) {
        final idx = entry.key + 1;
        final label = entry.value.key;
        final value = entry.value.value;
        final ratio = (value / safeMax).clamp(0.0, 1.0);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '$idx',
                  style: TextStyle(
                    fontFamily: 'Nanum',
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Nanum',
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$value',
                style: TextStyle(
                  fontFamily: 'Nanum',
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}