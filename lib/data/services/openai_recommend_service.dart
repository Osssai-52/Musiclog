import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../domain/services/recommend_service.dart';
import '../../domain/services/recommend_request.dart';
import '../../domain/models/recommendation_result.dart';
import '../../domain/models/song.dart';

class OpenAiRecommendService implements RecommendService {
  final String apiKey;

  OpenAiRecommendService({required this.apiKey}) {
    if (apiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY is empty. Did you forget --dart-define?');
    }
  }

  @override
  Future<RecommendationResult> recommend({
    required String diaryEntryId,
    required RecommendRequest request,
  }) async {
    final prompt = _buildPrompt(
      diaryText: request.diaryText,
      catalog: request.catalog,
      excludedSongIds: request.excludedSongIds.toList(),
    );

    final responseJson = await _callChatCompletions(prompt);

    final songId = responseJson['songId'] as String?;
    if (songId == null) throw Exception('GPT did not return songId');

    final double confidence =
    (responseJson['confidence'] is num) ? (responseJson['confidence'] as num).toDouble() : 0.5;

    // matchedLines 파싱
    List<String> matchedLines = [];
    final raw = responseJson['matchedLines'];
    if (raw is List) {
      matchedLines = raw.whereType<String>().map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    if (matchedLines.length > 3) matchedLines = matchedLines.take(3).toList();
    matchedLines = matchedLines.map((s) => s.length > 90 ? s.substring(0, 90) : s).toList();

    if (songId == 'NONE') {
      return RecommendationResult(
        diaryEntryId: diaryEntryId,
        songId: 'NONE',
        reason: responseJson['reason'] as String? ?? '추천할 수 있는 곡이 없습니다.',
        matchedLines: const [],
        generatedAt: DateTime.now(),
        model: 'gpt-4o-mini',
        confidence: confidence,
      );
    }

    // 유효성 체크
    final chosen = request.catalog.where((s) => s.id == songId).toList();
    if (chosen.isEmpty) throw Exception('GPT returned invalid songId: $songId');

    // matchedLines가 snippet에서 온 게 맞는지(간단 검증)
    final snippet = (chosen.first.lyricsSnippet ?? '');
    if (snippet.isNotEmpty && matchedLines.isNotEmpty) {
      matchedLines = matchedLines.where((l) => snippet.contains(l)).toList();
    }

    return RecommendationResult(
      diaryEntryId: diaryEntryId,
      songId: songId,
      reason: responseJson['reason'] as String? ?? '추천 이유를 생성할 수 없습니다.',
      matchedLines: matchedLines,
      generatedAt: DateTime.now(),
      model: 'gpt-4o-mini',
      confidence: confidence,
    );
  }

  String _buildPrompt({
    required String diaryText,
    required List<Song> catalog,
    required List<String> excludedSongIds,
  }) {
    final availableSongs = catalog
        .where((s) => !excludedSongIds.contains(s.id))
        .map((s) {
      final snippet = (s.lyricsSnippet ?? '').trim();
      // snippet을 “후보 줄 묶음”으로 사용
      return [
        '- id: ${s.id}',
        '  title: ${s.title}',
        '  artist: ${s.artist}',
        if (snippet.isNotEmpty) '  lyricsSnippet:\n${snippet.split("\n").map((l) => "    - $l").join("\n")}',
      ].join('\n');
    })
        .join('\n');

    return '''
You are an AI that analyzes a diary and recommends ONE song from a given list.

[Diary]
$diaryText

[Song List]
$availableSongs

[Tasks]
1) Infer up to two primary emotions expressed in the diary.
2) Choose ONE emotionKeyword representing the overall mood.
3) Choose exactly ONE songId from the list.

[Matched Lines Rule]
- Output matchedLines: 1~3 short excerpts copied EXACTLY from the chosen song's lyricsSnippet lines above.
- Each excerpt must be <= 90 characters.
- If no suitable song exists, return songId="NONE" and matchedLines=[].

[Response Rules]
- reason must be in Korean, 1~2 sentences, focused on musical mood/tone. No counseling.
- Output strictly valid JSON only. No extra text.
- confidence must be between 0.0 and 1.0.

[Output JSON]
{
  "emotions": ["string", "string"],
  "emotionKeyword": "string",
  "songId": "string",
  "reason": "string",
  "matchedLines": ["string"],
  "confidence": 0.0
}
''';
  }

  Future<Map<String, dynamic>> _callChatCompletions(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': 'You are an emotion-based music recommendation AI.'},
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.4,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('OpenAI API Error (${response.statusCode}): ${utf8.decode(response.bodyBytes)}');
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final content = decoded['choices']?[0]?['message']?['content'] as String?;

    if (content == null || content.isEmpty) throw Exception('GPT returned empty response');

    try {
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Failed to parse GPT JSON:\n$content');
    }
  }
}