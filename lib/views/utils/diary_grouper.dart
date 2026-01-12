import 'package:musiclog/domain/models/diary_entry.dart';

class MonthGroup {
  final int year;
  final int month;
  final List<DiaryEntry> entries;

  MonthGroup({
    required this.year,
    required this.month,
    required this.entries,
  });

  String get monthLabel => '$year년 $month월';
}

class DiaryGrouper {
  /// DiaryEntry 리스트를 월별로 그루핑
  static List<MonthGroup> groupByMonth(List<DiaryEntry> entries) {
    if (entries.isEmpty) return [];

    final grouped = <String, List<DiaryEntry>>{};

    for (final entry in entries) {
      final key = '${entry.date.year}-${entry.date.month}';
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(entry);
    }

    // 월별로 정렬 (최신순)
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        final aParts = a.split('-');
        final bParts = b.split('-');

        final aYear = int.parse(aParts[0]);
        final aMonth = int.parse(aParts[1]);
        final bYear = int.parse(bParts[0]);
        final bMonth = int.parse(bParts[1]);

        // 최신순 정렬
        final aDate = DateTime(aYear, aMonth);
        final bDate = DateTime(bYear, bMonth);
        return bDate.compareTo(aDate);
      });

    return sortedKeys.map((key) {
      final parts = key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthEntries = grouped[key]!;

      monthEntries.sort((a, b) => b.date.compareTo(a.date));

      return MonthGroup(
        year: year,
        month: month,
        entries: monthEntries,
      );
    }).toList();
  }
}
