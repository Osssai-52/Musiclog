import 'package:flutter/material.dart';
import 'di/app_dependencies.dart';

void main() {
  final dependencies = AppDependencies();
  runApp(MyApp(dependencies: dependencies));
}

class MyApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MyApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musiclog',
      home: HomePage(dependencies: dependencies),
    );
  }
}

class HomePage extends StatefulWidget {
  final AppDependencies dependencies;

  const HomePage({super.key, required this.dependencies});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _lastResult;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showFirstSnippet() async {
    setState(() {
      _loading = true;
      _lastResult = null;
    });

    try {
      final songs = await widget.dependencies.songCatalogRepository.getTopSongs();
      if (songs.isEmpty) {
        setState(() => _lastResult = 'TopSongs가 비어있음');
        return;
      }

      final s = songs.first;
      setState(() {
        _lastResult =
        'TITLE: ${s.title}\n'
            'ARTIST: ${s.artist}\n'
            'ID: ${s.id}\n'
            '\n[SNIPPET]\n${s.lyricsSnippet ?? "(null)"}';
      });
    } catch (e) {
      setState(() => _lastResult = '에러: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _recommend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _loading = true;
      _lastResult = null;
    });

    try {
      final result = await widget.dependencies.recommendSongUseCase.execute(
        diaryEntryId: 'test-diary',
        diaryText: text,
      );

      final top10 = widget.dependencies.recommendSongUseCase.lastTop10Scores;
      final top10Text = top10.isEmpty
          ? '(top10 없음)'
          : top10.asMap().entries.map((e) {
        final i = e.key + 1;
        final item = e.value;
        final score = (item['score'] as double).toStringAsFixed(4);
        return '$i) ${item['title']} - ${item['artist']} (id=${item['id']}) score=$score';
      }).join('\n');

      setState(() {
        _lastResult =
        '[RECOMMEND RESULT]\n'
            'songId: ${result.songId}\n'
            'reason: ${result.reason}\n'
            'matchedLines: ${result.matchedLines.join(" | ")}\n'
            'confidence: ${result.confidence}\n'
            'model: ${result.model}\n'
            '\n[EMBEDDING TOP 10]\n'
            '$top10Text';
      });
    } catch (e) {
      setState(() => _lastResult = '에러: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Musiclog')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '오늘 일기 내용',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _loading ? null : _showFirstSnippet,
              child: const Text('스니펫 확인(첫 곡)'),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _loading ? null : _recommend,
              child: Text(_loading ? '추천 중...' : '추천받기'),
            ),

            const SizedBox(height: 12),
            if (_lastResult != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(_lastResult!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}