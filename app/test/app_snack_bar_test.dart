import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fibonanci_app/presentation/widgets/common/common_widgets.dart';

void main() {
  Widget buildTestHost({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  testWidgets('AppSnackBar.showSuccess renders TactileToastCard with success theme and tag', (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSnackBar.showSuccess(
              context,
              'Tagihan Berhasil Lunas!',
              message: 'Saldo SeaBank otomatis terpotong Rp 160.000',
              tag: 'LUNAS',
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(TactileToastCard), findsOneWidget);
    expect(find.text('LUNAS'), findsOneWidget);
    expect(find.text('Tagihan Berhasil Lunas!'), findsOneWidget);
    expect(find.text('Saldo SeaBank otomatis terpotong Rp 160.000'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
  });

  testWidgets('AppSnackBar.showWarning renders warning theme and PERHATIAN tag', (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSnackBar.showWarning(
              context,
              'Rekening Tidak Valid',
              message: 'Rekening asal dan tujuan tidak boleh sama!',
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(TactileToastCard), findsOneWidget);
    expect(find.text('PERHATIAN'), findsOneWidget);
    expect(find.text('Rekening Tidak Valid'), findsOneWidget);
    expect(find.text('Rekening asal dan tujuan tidak boleh sama!'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('AppSnackBar.showError renders error theme and HAPUS tag', (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSnackBar.showError(
              context,
              'Transaksi Dihapus',
              message: 'Saldo dompet dikembalikan semula',
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(TactileToastCard), findsOneWidget);
    expect(find.text('HAPUS'), findsOneWidget);
    expect(find.text('Transaksi Dihapus'), findsOneWidget);
    expect(find.text('Saldo dompet dikembalikan semula'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
  });

  testWidgets('AppSnackBar.showInfo renders info theme and invokes action callback', (tester) async {
    var actionClicked = false;
    await tester.pumpWidget(
      buildTestHost(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSnackBar.showInfo(
              context,
              'Nomor Rekening Disalin',
              message: 'BCA 123456 siap ditempel',
              actionLabel: 'URUNGKAN',
              onAction: () => actionClicked = true,
            ),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(TactileToastCard), findsOneWidget);
    expect(find.text('INFO'), findsOneWidget);
    expect(find.text('URUNGKAN'), findsOneWidget);

    await tester.tap(find.text('URUNGKAN'));
    await tester.pump();
    expect(actionClicked, isTrue);
  });

  testWidgets('TactileToastCard dismisses on swipe down', (tester) async {
    await tester.pumpWidget(
      buildTestHost(
        child: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => AppSnackBar.showSuccess(context, 'Sukses Disimpan'),
            child: const Text('Show'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byType(TactileToastCard), findsOneWidget);

    // Swipe down to dismiss
    await tester.drag(find.byKey(const Key('tactile_toast_dismissible')), const Offset(0, 200));
    await tester.pumpAndSettle();

    expect(find.byType(TactileToastCard), findsNothing);
  });
}
