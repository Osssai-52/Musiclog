import 'package:flutter/material.dart';
import 'package:musiclog/data/dummy/diary.dart';
import 'package:musiclog/data/dummy/song_catalog.dart';
import 'package:musiclog/views/calendar_view.dart';
import 'package:musiclog/views/list_view.dart';
import 'package:musiclog/config/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  late final songRepository = DummySongCatalogRepository();
  late final diaryRepository = DummyDiaryRepository();
  final List<String> _tabTitles = ['List View', 'Calendar View', 'Settings'];

  List<Widget> get _tabs => [
    DiaryListView(songRepository: songRepository, diaryRepository: diaryRepository),
    CalendarView(songRepository: songRepository, diaryRepository: diaryRepository),
    const Placeholder(),
  ];

  @override
  void initState() {
    super.initState();
    _initRepositories();
  }

  Future<void> _initRepositories() async {
    await songRepository.init();
    setState(() {});
  }

  void _switchTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< Updated upstream
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
              actions: [
                IconButton(onPressed: null, icon: const Icon(Icons.light_mode))
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
              duration: Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _tabs[_selectedIndex],
              key: ValueKey(_selectedIndex),  // 필수!
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
            )
=======
      title: 'Musiclog',
      home: HomePage(dependencies: dependencies),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppDependencies dependencies;

  const HomePage({
    super.key,
    required this.dependencies,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _diaryController = TextEditingController();
  bool loading = false;
  String resultText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musiclog – GPT 추천 테스트'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _diaryController,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: '오늘의 일기를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : _recommend,
              child: const Text('노래 추천받기'),
            ),
            const SizedBox(height: 16),
            if (loading)
              const Center(child: CircularProgressIndicator()),
            if (resultText.isNotEmpty)
              Text(
                resultText,
                style: const TextStyle(fontSize: 16),
              ),
>>>>>>> Stashed changes
          ],
        ),
      ),
    );
  }

  Future<void> _recommend() async {
    setState(() {
      loading = true;
      resultText = '';
    });

    try {
      final result =
          await widget.dependencies.recommendSongUseCase.execute(
        diaryEntryId: 'test-diary',
        diaryText: _diaryController.text,
      );

      setState(() {
        resultText = '''
🎵 추천 결과

songId: ${result.songId}
이유: ${result.reason}
감정: ${result.matchedLines.join(', ')}
''';
      });
    } catch (e) {
      setState(() {
        resultText = '❌ 오류 발생\n$e';
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }
}
