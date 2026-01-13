List<String> extractSnippetCandidates(String lyricsFull, {int maxLines = 10}) {
  final raw = lyricsFull
      .split(RegExp(r'\r?\n'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  bool isTagLine(String s) =>
      RegExp(r'^\[.*\]$').hasMatch(s) || RegExp(r'^\(.*\)$').hasMatch(s);

  bool isLowSignal(String s) {
    final t = s.toLowerCase();
    if (t.length <= 4) return true;
    if (RegExp(r'^(oh|yeah|yah|woo+|la+|na+|hey)$').hasMatch(t)) return true;
    return false;
  }

  final lines = raw
      .where((l) => !isTagLine(l))
      .where((l) => l.length >= 8)
      .where((l) => !isLowSignal(l))
      .toList();

  if (lines.isEmpty) return [];

  String norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[\p{P}\p{S}]', unicode: true), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  final freq = <String, int>{};
  for (final l in lines) {
    final k = norm(l);
    if (k.isEmpty) continue;
    freq[k] = (freq[k] ?? 0) + 1;
  }

  int scoreLine(String l) {
    final f = freq[norm(l)] ?? 1;
    final len = l.length;
    final tooLongPenalty = (len > 140) ? 5 : 0;
    final tooShortPenalty = (len < 14) ? 2 : 0;
    return f * 10 - tooLongPenalty - tooShortPenalty;
  }

  final scored = lines.map((l) => MapEntry(l, scoreLine(l))).toList();
  scored.sort((a, b) => b.value.compareTo(a.value));

  final out = <String>[];
  final seen = <String>{};

  for (final e in scored) {
    final k = norm(e.key);
    if (k.isEmpty || seen.contains(k)) continue;
    seen.add(k);

    final clipped = e.key.length > 120 ? e.key.substring(0, 120) : e.key;
    out.add(clipped);

    if (out.length >= maxLines) break;
  }
  return out;
}

String buildLyricsSnippetFromFull(String? lyricsFull, {int maxLines = 10}) {
  if (lyricsFull == null || lyricsFull.trim().isEmpty) return '';
  final lines = extractSnippetCandidates(lyricsFull, maxLines: maxLines);
  return lines.join('\n');
}