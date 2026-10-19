import 'package:drift/drift.dart';
import 'package:fibonanci_app/data/database/app_database.dart';
import 'package:fibonanci_app/presentation/widgets/expense_category_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionVisualResolver Unit Tests', () {
    final now = DateTime(2026, 10, 20, 10, 0);

    test('resolves pocket deposit and withdrawal with pocket gold or custom pastel', () {
      final pocketTx = TransactionEntry(
        id: 'tx_p1',
        walletId: 'w1',
        categoryId: 'cat_transfer',
        amount: 250000.0,
        type: 'expense',
        notes: 'Setoran ke Kantong Liburan',
        transactionDate: now,
        source: 'manual',
        externalRef: 'pocket_liburan',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final visual = TransactionVisualResolver.resolve(
        tx: pocketTx,
        pockets: [
          PocketEntry(
            id: 'liburan',
            name: 'Liburan',
            type: 'savings',
            colorHex: '#3B82F6',
            iconName: 'savings',
            currentAmount: 250000.0,
            createdAt: now,
            updatedAt: now,
            isSynced: false,
            isDeleted: false,
          ),
        ],
      );

      expect(visual.categoryLabel, 'KANTONG • LIBURAN');
      expect(visual.iconData, Icons.savings_rounded);
      expect(visual.cardColor, isNot(Colors.black));

      // Test generic pocket withdrawal without pocket entity
      final withdrawTx = pocketTx.copyWith(
        notes: const Value('Penarikan dari Kantong Darurat'),
        externalRef: const Value('pocket_close_darurat'),
      );
      final withdrawVisual = TransactionVisualResolver.resolve(tx: withdrawTx);
      expect(withdrawVisual.categoryLabel, 'PENARIKAN KANTONG');
      expect(withdrawVisual.cardColor, TransactionVisualResolver.pocketGold);
      expect(withdrawVisual.iconData, Icons.north_east_rounded);
    });

    test('resolves inter-wallet transfers with soft periwinkle blue and swap icon', () {
      final transferTx = TransactionEntry(
        id: 'tx_t1',
        walletId: 'w_bca',
        destinationWalletId: 'w_gopay',
        categoryId: '11111111-1111-4111-8111-111111111111',
        amount: 50000.0,
        type: 'transfer',
        notes: 'Top Up Saldo GoPay',
        transactionDate: now,
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final visual = TransactionVisualResolver.resolve(
        tx: transferTx,
        destWalletName: 'GoPay',
      );

      expect(visual.categoryLabel, 'TRANSFER SALDO');
      expect(visual.iconData, Icons.swap_horiz_rounded);
      expect(visual.cardColor, TransactionVisualResolver.transferBlue);
      expect(visual.title, 'Top Up Saldo GoPay');
    });

    test('resolves income types with neo-mint palette and semantic labels', () {
      final salaryTx = TransactionEntry(
        id: 'tx_inc1',
        walletId: 'w1',
        categoryId: 'cat_salary',
        amount: 8000000.0,
        type: 'income',
        notes: 'Gaji Bulan Oktober PT Maju',
        transactionDate: now,
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final salaryVisual = TransactionVisualResolver.resolve(tx: salaryTx);
      expect(salaryVisual.categoryLabel, 'GAJI & PENDAPATAN');
      expect(salaryVisual.cardColor, TransactionVisualResolver.incomeMint);
      expect(salaryVisual.iconData, Icons.account_balance_wallet_rounded);

      final bonusTx = salaryTx.copyWith(notes: const Value('Bonus Freelance Mobile App'));
      final bonusVisual = TransactionVisualResolver.resolve(tx: bonusTx);
      expect(bonusVisual.categoryLabel, 'BONUS & FREELANCE');
      expect(bonusVisual.iconData, Icons.auto_awesome_rounded);

      final cashbackTx = salaryTx.copyWith(notes: const Value('Cashback Promo 10rb'));
      final cashbackVisual = TransactionVisualResolver.resolve(tx: cashbackTx);
      expect(cashbackVisual.categoryLabel, 'CASHBACK & REFUND');
      expect(cashbackVisual.iconData, Icons.card_giftcard_rounded);
    });

    test('resolves standard expense categories with curated neo-pastel tones', () {
      final baseTx = TransactionEntry(
        id: 'tx_e1',
        walletId: 'w1',
        categoryId: 'cat_food',
        amount: 45000.0,
        type: 'expense',
        notes: 'Kopi Kenangan Senopati',
        transactionDate: now,
        source: 'manual',
        createdAt: now,
        updatedAt: now,
        isSynced: false,
        isDeleted: false,
      );

      final foodVisual = TransactionVisualResolver.resolve(tx: baseTx);
      expect(foodVisual.categoryLabel, 'MAKANAN & MINUMAN');
      expect(foodVisual.cardColor, TransactionVisualResolver.foodOchre);
      expect(foodVisual.iconData, Icons.restaurant_rounded);

      final transportTx = baseTx.copyWith(notes: const Value('Gojek ke Stasiun'));
      final transportVisual = TransactionVisualResolver.resolve(tx: transportTx);
      expect(transportVisual.categoryLabel, 'TRANSPORTASI');
      expect(transportVisual.cardColor, TransactionVisualResolver.transportTeal);
      expect(transportVisual.iconData, Icons.directions_car_rounded);

      final shoppingTx = baseTx.copyWith(notes: const Value('Belanja Mingguan Indomaret'));
      final shoppingVisual = TransactionVisualResolver.resolve(tx: shoppingTx);
      expect(shoppingVisual.categoryLabel, 'BELANJA');
      expect(shoppingVisual.cardColor, TransactionVisualResolver.shoppingCoral);

      final billsTx = baseTx.copyWith(notes: const Value('Tagihan Listrik PLN Pascabayar'));
      final billsVisual = TransactionVisualResolver.resolve(tx: billsTx);
      expect(billsVisual.categoryLabel, 'TAGIHAN & UTILITAS');
      expect(billsVisual.cardColor, TransactionVisualResolver.billsPeriwinkle);

      final entertainmentTx = baseTx.copyWith(notes: const Value('Langganan Netflix Premium'));
      final entertainmentVisual = TransactionVisualResolver.resolve(tx: entertainmentTx);
      expect(entertainmentVisual.categoryLabel, 'HIBURAN');
      expect(entertainmentVisual.cardColor, TransactionVisualResolver.entertainmentLilac);

      final healthTx = baseTx.copyWith(notes: const Value('Beli Vitamin di Apotek Kimia Farma'));
      final healthVisual = TransactionVisualResolver.resolve(tx: healthTx);
      expect(healthVisual.categoryLabel, 'KESEHATAN');
      expect(healthVisual.cardColor, TransactionVisualResolver.healthRose);
    });

    test('tintToPastel produces readable high-contrast pastels and defaults safely', () {
      final pastel = TransactionVisualResolver.tintToPastel('#FF0000');
      expect(pastel, isNot(Colors.transparent));
      expect(TransactionVisualResolver.tintToPastel('invalid_hex'), TransactionVisualResolver.defaultSlate);
    });
  });
}
