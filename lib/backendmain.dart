import 'package:flutter/material.dart';
import 'di/app_dependencies.dart';

void main() {
  final dependencies = AppDependencies();
  runApp(MyApp(dependencies: dependencies));
}

class MyApp extends StatelessWidget {
  final AppDependencies dependencies;

  const MyApp({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Musiclog',
      home: HomePage(dependencies: dependencies),
    );
  }
}

class HomePage extends StatelessWidget {
  final AppDependencies dependencies;

  const HomePage({
    super.key,
    required this.dependencies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Musiclog'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final diaryEntryId = 'test-diary';

            final result =
                await dependencies.recommendSongUseCase.execute(
              diaryEntryId: diaryEntryId,
              diaryText: '오늘은 조금 우울했다',
            );

            debugPrint('추천 결과 songId: ${result.songId}');
          },
          child: const Text('추천받기'),
        ),
      ),
    );
  }
}
