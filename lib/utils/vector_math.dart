import 'dart:math' as math;

double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw Exception('Embedding dimension mismatch: ${a.length} vs ${b.length}');
  }
  double dot = 0;
  double na = 0;
  double nb = 0;

  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    na += a[i] * a[i];
    nb += b[i] * b[i];
  }

  final denom = math.sqrt(na) * math.sqrt(nb);
  if (denom == 0) return 0;
  return dot / denom;
}