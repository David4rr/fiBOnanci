enum ChangelogType {
  feature('Fitur Baru'),
  improvement('Peningkatan & Performa'),
  fix('Perbaikan Bug'),
  other('Pembaruan Sistem');

  final String title;
  const ChangelogType(this.title);
}

class ChangelogCategory {
  final ChangelogType type;
  final List<String> items;

  const ChangelogCategory({required this.type, required this.items});
}

class ChangelogFormatter {
  static List<ChangelogCategory> parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return _defaultCategories();
    }

    final features = <String>[];
    final improvements = <String>[];
    final fixes = <String>[];
    final others = <String>[];

    final lines = raw
        .replaceAll('\r\n', '\n')
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !_isIgnoredHeader(l))
        .toList();

    for (final line in lines) {
      final cleaned = _cleanLine(line);
      if (cleaned.isEmpty) continue;

      final lower = line.toLowerCase();
      if (_isFeature(lower)) {
        features.add(cleaned);
      } else if (_isImprovement(lower)) {
        improvements.add(cleaned);
      } else if (_isFix(lower)) {
        fixes.add(cleaned);
      } else {
        others.add(cleaned);
      }
    }

    final result = <ChangelogCategory>[];
    if (features.isNotEmpty) {
      result.add(ChangelogCategory(type: ChangelogType.feature, items: features));
    }
    if (improvements.isNotEmpty) {
      result.add(ChangelogCategory(type: ChangelogType.improvement, items: improvements));
    }
    if (fixes.isNotEmpty) {
      result.add(ChangelogCategory(type: ChangelogType.fix, items: fixes));
    }
    if (others.isNotEmpty) {
      result.add(ChangelogCategory(type: ChangelogType.other, items: others));
    }

    return result.isNotEmpty ? result : _defaultCategories();
  }

  static bool _isIgnoredHeader(String l) {
    final lower = l.toLowerCase();
    return lower.startsWith('## what\'s changed') ||
        lower.startsWith('## changelog') ||
        lower.startsWith('**full changelog**') ||
        lower.startsWith('full changelog:');
  }

  static bool _isFeature(String l) {
    return l.contains('feat:') ||
        l.contains('feature:') ||
        l.contains('feat(') ||
        l.contains('✨') ||
        l.contains('tambah') ||
        l.contains('fitur');
  }

  static bool _isImprovement(String l) {
    return l.contains('perf:') ||
        l.contains('improve:') ||
        l.contains('refactor:') ||
        l.contains('⚡') ||
        l.contains('optim') ||
        l.contains('peningkatan');
  }

  static bool _isFix(String l) {
    return l.contains('fix:') ||
        l.contains('bug:') ||
        l.contains('fix(') ||
        l.contains('🐛') ||
        l.contains('perbaikan') ||
        l.contains('patch');
  }

  static String _cleanLine(String line) {
    var s = line
        .replaceAll(RegExp(r'^[*\-•#]+\s*'), '')
        .replaceAll(RegExp(r'^(feat|fix|perf|refactor|chore|docs|style)(\([^)]*\))?:\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+in\s+https://github\.com/\S+'), '')
        .replaceAll(RegExp(r'\s+in\s+#\d+'), '')
        .replaceAll(RegExp(r'\s+by\s+@[\w-]+'), '')
        .trim();

    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  static List<ChangelogCategory> _defaultCategories() => const [
        ChangelogCategory(
          type: ChangelogType.improvement,
          items: [
            'Peningkatan kestabilan, responsivitas, dan efisiensi memori.',
            'Optimasi pemrosesan lokal notifikasi perbankan.',
          ],
        ),
        ChangelogCategory(
          type: ChangelogType.fix,
          items: [
            'Perbaikan bug visual dan performa database terenkripsi.',
          ],
        ),
      ];
}
