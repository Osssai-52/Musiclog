class RecommendationResult {
    final String diaryEntryId;
    final String songId;
    final String reason;
    final List<String> matchedLines;
    final DateTime generatedAt;

    RecommendationResult({
        required this.diaryEntryId,
        required this.songId,
        required this.reason,
        required this.matchedLines,
        required this.generatedAt,
    });
}
