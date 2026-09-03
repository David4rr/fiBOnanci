import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';

class DefaultWalletSeedData {
  final List<WalletsCompanion> wallets;
  final List<NotificationRulesCompanion> rules;

  const DefaultWalletSeedData({required this.wallets, required this.rules});
}

DefaultWalletSeedData getDefaultWalletsSeed(DateTime now) {
  const uuid = Uuid();
  final defaultWallets = [
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('BCA Utama'),
      type: const Value('bank'),
      balance: const Value(2500000.0),
      colorHex: const Value('#0060AF'),
      iconName: const Value('landmark'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('blu by BCA'),
      type: const Value('bank'),
      balance: const Value(1200000.0),
      colorHex: const Value('#00A4E4'),
      iconName: const Value('credit_card'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('SeaBank'),
      type: const Value('bank'),
      balance: const Value(850000.0),
      colorHex: const Value('#FF5722'),
      iconName: const Value('shield_check'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('Livin Mandiri'),
      type: const Value('bank'),
      balance: const Value(3400000.0),
      colorHex: const Value('#002D62'),
      iconName: const Value('building_2'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('Bank Jago'),
      type: const Value('bank'),
      balance: const Value(950000.0),
      colorHex: const Value('#FF7300'),
      iconName: const Value('sparkles'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('OVO Cash'),
      type: const Value('ewallet'),
      balance: const Value(350000.0),
      colorHex: const Value('#4C3494'),
      iconName: const Value('smartphone'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    WalletsCompanion(
      id: Value(uuid.v4()),
      name: const Value('ShopeePay'),
      type: const Value('ewallet'),
      balance: const Value(19259.0),
      colorHex: const Value('#EE4D2D'),
      iconName: const Value('shopping_bag'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
  ];

  final defaultRules = [
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.bca'),
      walletId: defaultWallets[0].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.bca.mybca'),
      walletId: defaultWallets[0].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.bcadigital.blu'),
      walletId: defaultWallets[1].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.seabank.id'),
      walletId: defaultWallets[2].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.bankmandiri.livin'),
      walletId: defaultWallets[3].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.bankjago.app'),
      walletId: defaultWallets[4].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('ovo.id'),
      walletId: defaultWallets[5].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
    NotificationRulesCompanion(
      id: Value(uuid.v4()),
      packageName: const Value('com.shopee.id'),
      walletId: defaultWallets[6].id,
      createdAt: Value(now),
      updatedAt: Value(now),
    ),
  ];

  return DefaultWalletSeedData(wallets: defaultWallets, rules: defaultRules);
}
