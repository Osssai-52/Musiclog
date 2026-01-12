class RecommendationResult {
    final String diaryEntryId;
    final String songId;
    final String reason;
    final List<String> matchedLines;
    final DateTime generatedAt;
    final String model;
    final double? confidence;

    RecommendationResult({
        required this.diaryEntryId,
        required this.songId,
        required this.reason,
        required this.matchedLines,
        required this.generatedAt,
        required this.model,
        this.confidence,
    });

    // JSON 데이터를 객체로 변환하는 생성자 추가
    factory RecommendationResult.fromGeminiJson({
        required Map<String, dynamic> json,
        required String diaryEntryId,
        required String modelName,
    }) {
        return RecommendationResult(
        diaryEntryId: diaryEntryId,
        songId: json['songId'] as String? ?? 'unknown',
        reason: json['reason'] as String? ?? '',
        matchedLines: [json['matchedEmotion'] as String? ?? ''],
        generatedAt: DateTime.now(),
        model: modelName,
        );
    }
}
