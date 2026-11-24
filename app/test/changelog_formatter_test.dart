import 'package:flutter_test/flutter_test.dart';
import 'package:fibonanci_app/core/update/changelog_formatter.dart';

void main() {
  group('ChangelogFormatter Tests', () {
    test('returns default categories when raw text is null or empty', () {
      final resNull = ChangelogFormatter.parse(null);
      expect(resNull.isNotEmpty, isTrue);
      expect(resNull.any((c) => c.type == ChangelogType.improvement), isTrue);

      final resEmpty = ChangelogFormatter.parse('   \n  ');
      expect(resEmpty.isNotEmpty, isTrue);
    });

    test('categorizes conventional commit tags correctly', () {
      const raw = '''
## What's Changed
* feat: dynamic theme switching with espresso walnut in #45
* fix: history tap navigation bug by @David4rr in #46
* perf: sqlite query indexing speedup
* chore: bump version to 1.0.5
**Full Changelog**: https://github.com/David4rr/fiBOnanci/commits
''';

      final categories = ChangelogFormatter.parse(raw);
      expect(categories.length, 4);

      final featCat = categories.firstWhere((c) => c.type == ChangelogType.feature);
      expect(featCat.items.first, contains('Dynamic theme switching'));
      expect(featCat.items.first, isNot(contains('#45')));
      expect(featCat.items.first, isNot(contains('feat:')));

      final fixCat = categories.firstWhere((c) => c.type == ChangelogType.fix);
      expect(fixCat.items.first, contains('History tap navigation bug'));
      expect(fixCat.items.first, isNot(contains('@David4rr')));

      final perfCat = categories.firstWhere((c) => c.type == ChangelogType.improvement);
      expect(perfCat.items.first, contains('Sqlite query indexing speedup'));

      final otherCat = categories.firstWhere((c) => c.type == ChangelogType.other);
      expect(otherCat.items.first, contains('Bump version to 1.0.5'));
    });

    test('categorizes emojis correctly', () {
      const raw = '''
✨ Fitur kesehatan finansial baru
⚡ Peningkatan kecepatan animasi
🐛 Perbaikan bug modal profile
''';

      final categories = ChangelogFormatter.parse(raw);
      expect(categories.any((c) => c.type == ChangelogType.feature), isTrue);
      expect(categories.any((c) => c.type == ChangelogType.improvement), isTrue);
      expect(categories.any((c) => c.type == ChangelogType.fix), isTrue);
    });
  });
}
