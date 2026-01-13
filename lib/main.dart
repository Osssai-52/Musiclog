import 'package:flutter/material.dart';
import 'package:musiclog/data/dummy/diary.dart';
import 'package:musiclog/data/dummy/song_catalog.dart';
import 'package:musiclog/views/calendar_view.dart';
import 'package:musiclog/views/list_view.dart';
import 'package:musiclog/config/app_colors.dart';
import 'package:musiclog/views/widgets/diary_edit_dialog.dart';
import 'package:musiclog/domain/models/diary_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musiclog/di/app_dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  final dependencies = AppDependencies();
  runApp(MyApp(dependencies: dependencies));
}

class MyApp extends StatefulWidget {
  final AppDependencies dependencies;
  const MyApp({super.key, required this.dependencies});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

  int _selectedIndex = 0;
  late final songRepository = DummySongCatalogRepository();
  late final diaryRepository = DummyDiaryRepository();

  bool _todayHasDiary = false;
  bool _todayStatusLoading = true;

  List<Widget> get _tabs =>
      [
        DiaryListView(
            songRepository: songRepository, diaryRepository: diaryRepository),
        CalendarView(
            songRepository: songRepository, diaryRepository: diaryRepository, dependencies: widget.dependencies),
        const Placeholder(),
      ];

  @override
  void initState() {
    super.initState();
    _initRepositories();
    _refreshTodayStatus();
  }

  Future<void> _initRepositories() async {
    await songRepository.init();
    if (mounted) setState(() {});
  }

  int _dayKey(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  Future<void> _refreshTodayStatus() async {
    setState(() {
      _todayStatusLoading = true;
    });

    try {
      final List<DiaryEntry> entries = await diaryRepository.listAll();
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
    final nav = _navKey.currentState;
    if (nav == null) return;

    final ctx = nav.overlay!.context;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final result = await showDialog<String>(
      context: ctx,
      useRootNavigator: true,
      builder: (context) =>
          DiaryEditDialog(
            diaryRepository: diaryRepository,
            songRepository: songRepository,
            recommendSongUseCase: widget.dependencies.recommendSongUseCase,
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

  @override
  Widget build(BuildContext context) {
    final showAdd = _selectedIndex == 0;
    final addEnabled = showAdd && !_todayStatusLoading && !_todayHasDiary;

    return MaterialApp(
      navigatorKey: _navKey,
      title: 'Music Log',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      ),
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
              child: _tabs[_selectedIndex],
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
                        _selectedIndex == 1 ? Icons.album : Icons
                            .album_outlined,
                        color: _selectedIndex == 1
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 26,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _switchTab(2),
                      child: Icon(
                        _selectedIndex == 2 ? Icons.settings : Icons
                            .settings_outlined,
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