import 'package:flutter/material.dart';
import 'package:musiclog/data/dummy/diary.dart';
import 'package:musiclog/data/dummy/song_catalog.dart';
import 'package:musiclog/views/calendar_view.dart';
import 'package:musiclog/views/list_view.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/views/widgets/diary_edit_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musiclog/di/app_dependencies.dart';
import 'package:musiclog/views/settings_view.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'data/repositories/used_songs_repository_prefs.dart';
import 'package:musiclog/views/insights_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  AppDependencies? _dependencies;
  bool _depsReady = false;

  int _selectedIndex = 0;

  late final songRepository = DummySongCatalogRepository();
  late final diaryRepository = DummyDiaryRepository();

  bool _todayHasDiary = false;
  bool _todayStatusLoading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _openInsights() async {
    final nav = _navKey.currentState;
    if (nav == null) return;

    await nav.push(
      MaterialPageRoute(
        builder: (_) => InsightsView(
          diaryRepository: diaryRepository,
          songRepository: songRepository,
        ),
      ),
    );
  }

  Future<void> _resetUsedSongs() async {
    final deps = _dependencies;
    if (!_depsReady || deps == null) return;

    if (deps.usedSongsRepository is UsedSongsRepositoryPrefs) {
      await (deps.usedSongsRepository as UsedSongsRepositoryPrefs).clearAll();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(_navKey.currentState!.overlay!.context).showSnackBar(
      SnackBar(
        content: const Text('Used songs have been reset.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }
  Future<void> _clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('draft_')).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(_navKey.currentState!.overlay!.context).showSnackBar(
      SnackBar(
        content: const Text('Drafts have been cleared.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _exportJson() async {
    final entries = await diaryRepository.listAll(newestFirst: false);

    final data = entries.map((e) {
      final rec = e.recommendation;
      return {
        'id': e.id,
        'date': e.date.toIso8601String(),
        'content': e.content,
        'createdAt': e.createdAt.toIso8601String(),
        'updatedAt': e.updatedAt.toIso8601String(),
        'recommendedSongId': e.recommendedSongId,
        'recommendation': rec == null
            ? null
            : {
          'diaryEntryId': rec.diaryEntryId,
          'songId': rec.songId,
          'reason': rec.reason,
          'matchedLines': rec.matchedLines,
          'generatedAt': rec.generatedAt.toIso8601String(),
          'model': rec.model,
          'confidence': rec.confidence,
        },
      };
    }).toList();

    final jsonString = const JsonEncoder.withIndent('  ').convert({'entries': data});

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/entries.json');
    await file.writeAsString(jsonString, encoding: utf8);

    await Share.shareXFiles([XFile(file.path)], text: 'MusicLog entries.json');
  }

  Future<void> _exportMarkdown() async {
    final entries = await diaryRepository.listAll(newestFirst: false);

    String esc(String s) => s.replaceAll('\r\n', '\n');

    final sb = StringBuffer();
    sb.writeln('# MusicLog');
    sb.writeln();

    for (final e in entries) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      final dateStr =
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      sb.writeln('## $dateStr');
      sb.writeln();

      sb.writeln(esc(e.content).trim());
      sb.writeln();

      final rec = e.recommendation;
      final songId = rec?.songId ?? e.recommendedSongId;

      if (songId != null) {
        sb.writeln('### Recommendation');
        sb.writeln();
        sb.writeln('- songId: $songId');

        if (rec != null) {
          sb.writeln('- confidence: ${rec.confidence.toStringAsFixed(2)}');
          sb.writeln('- model: ${rec.model}');
          sb.writeln('- reason: ${esc(rec.reason).trim()}');

          if (rec.matchedLines.isNotEmpty) {
            sb.writeln('- matchedLines:');
            for (final line in rec.matchedLines) {
              sb.writeln('  - ${esc(line).trim()}');
            }
          }
        }
        sb.writeln();
      }

      sb.writeln('---');
      sb.writeln();
    }

    final md = sb.toString();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/musiclog.md');
    await file.writeAsString(md, encoding: utf8);

    await Share.shareXFiles([XFile(file.path)], text: 'MusicLog markdown export');
  }

  Future<void> _bootstrap() async {
    try {
      await songRepository.init();

      final deps = AppDependencies(songCatalogRepositoryOverride: songRepository);
      await diaryRepository.seedRecommendations(deps.recommendSongUseCase);

      if (!mounted) return;
      setState(() {
        _dependencies = deps;
        _depsReady = true;
      });

      await _refreshTodayStatus();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _dependencies = null;
        _depsReady = false;
      });
      await _refreshTodayStatus();
    }
  }

  int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  Future<void> _refreshTodayStatus() async {
    if (!mounted) return;
    setState(() {
      _todayStatusLoading = true;
    });

    try {
      final entries = await diaryRepository.listAll();
      final now = DateTime.now();
      final todayKey = _dayKey(DateTime(now.year, now.month, now.day));

      final has = entries.any((e) {
        final d = e.date.toLocal();
        final key = _dayKey(DateTime(d.year, d.month, d.day));
        return key == todayKey;
      });

      if (!mounted) return;
      setState(() {
        _todayHasDiary = has;
        _todayStatusLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _todayHasDiary = false;
        _todayStatusLoading = false;
      });
    }
  }

  Future<void> _openTodayEdit() async {
    final deps = _dependencies;
    if (!_depsReady || deps == null) return;

    final nav = _navKey.currentState;
    if (nav == null) return;

    final ctx = nav.overlay!.context;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = await showDialog<String>(
      context: ctx,
      useRootNavigator: true,
      builder: (context) => DiaryEditDialog(
        diaryRepository: diaryRepository,
        songRepository: songRepository,
        recommendSongUseCase: deps.recommendSongUseCase,
        selectedDate: today,
      ),
    );

    if (result == 'refresh') {
      await _refreshTodayStatus();
      if (mounted) setState(() {});
    } else {
      await _refreshTodayStatus();
    }
  }

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _refreshTodayStatus();
    }
  }

  ThemeData _theme() {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardColor: AppColors.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_depsReady || _dependencies == null) {
      return MaterialApp(
        navigatorKey: _navKey,
        title: 'Music Log',
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final deps = _dependencies!;

    final tabs = <Widget>[
      DiaryListView(songRepository: songRepository, diaryRepository: diaryRepository),
      CalendarView(songRepository: songRepository, diaryRepository: diaryRepository, dependencies: deps),
      SettingsView(
        onExportMarkdown: _exportMarkdown,
        onExportJson: _exportJson,
        onOpenStats: _openInsights,
        onOpenAppearance: () {},
        onClearDrafts: _clearAllDrafts,
        onClearUsedSongs: _resetUsedSongs,
      ),
    ];

    final showAdd = _selectedIndex == 0;
    final addEnabled = showAdd && !_todayStatusLoading && !_todayHasDiary;

    return MaterialApp(
      navigatorKey: _navKey,
      title: 'Music Log',
      debugShowCheckedModeBanner: false,
      theme: _theme(),
      home: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight + 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AppBar(
              leading: showAdd
                  ? IconButton(
                icon: const Icon(Icons.add),
                onPressed: addEnabled ? _openTodayEdit : null,
              )
                  : null,
              actions: [
                IconButton(onPressed: null, icon: const Icon(Icons.light_mode)),
              ],
              scrolledUnderElevation: 0,
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
        body: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: tabs[_selectedIndex],
              key: ValueKey(_selectedIndex),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                height: 65,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _switchTab(0),
                      child: Icon(
                        _selectedIndex == 0 ? Icons.edit : Icons.edit_outlined,
                        color: _selectedIndex == 0
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _switchTab(1),
                      child: Icon(
                        _selectedIndex == 1 ? Icons.album : Icons.album_outlined,
                        color: _selectedIndex == 1
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _switchTab(2),
                      child: Icon(
                        _selectedIndex == 2 ? Icons.settings : Icons.settings_outlined,
                        color: _selectedIndex == 2
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}