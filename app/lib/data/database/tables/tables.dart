import 'package:drift/drift.dart';

// Mixin for syncable metadata across all entities
mixin SyncableTable on Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WalletEntry')
class Wallets extends Table with SyncableTable {
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => text()(); // bank, ewallet, cash, investment, other
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('IDR'))();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  TextColumn get colorHex => text().withLength(min: 7, max: 7).withDefault(const Constant('#10B981'))();
  TextColumn get iconName => text().withDefault(const Constant('wallet'))();
  TextColumn get accountNumber => text().nullable()();
}

@DataClassName('CategoryEntry')
class Categories extends Table with SyncableTable {
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => text()(); // expense, income
  TextColumn get iconName => text().withDefault(const Constant('category'))();
  TextColumn get colorHex => text().withLength(min: 7, max: 7).withDefault(const Constant('#64748B'))();
}

@DataClassName('TransactionEntry')
class Transactions extends Table with SyncableTable {
  @ReferenceName('transactions')
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // expense, income, transfer
  @ReferenceName('transfersReceived')
  TextColumn get destinationWalletId => text().nullable().references(Wallets, #id)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get source => text().withDefault(const Constant('manual'))(); // manual, notification_auto, etc.
  TextColumn get externalRef => text().nullable()();
}

@DataClassName('SubscriptionEntry')
class Subscriptions extends Table with SyncableTable {
  TextColumn get walletId => text().references(Wallets, #id)();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get title => text().withLength(min: 1, max: 128)();
  RealColumn get cost => real()();
  TextColumn get billingCycle => text().withDefault(const Constant('monthly'))();
  IntColumn get dueDay => integer()();
  BoolColumn get autoDeduct => boolean().withDefault(const Constant(false))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  DateTimeColumn get lastPaidDate => dateTime().nullable()();
}

@DataClassName('NotificationRuleEntry')
class NotificationRules extends Table with SyncableTable {
  TextColumn get packageName => text()();
  TextColumn get walletId => text().references(Wallets, #id)();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get autoConfirm => boolean().withDefault(const Constant(false))();
  TextColumn get defaultCategoryId => text().nullable().references(Categories, #id)();
}

@DataClassName('PocketEntry')
class Pockets extends Table with SyncableTable {
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get type => text().withDefault(const Constant('savings'))(); // emergency, retirement, savings, goal, other
  RealColumn get targetAmount => real().nullable()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get colorHex => text().withLength(min: 7, max: 7).withDefault(const Constant('#D4F442'))();
  TextColumn get iconName => text().withDefault(const Constant('savings'))();
  DateTimeColumn get targetDate => dateTime().nullable()();
  TextColumn get linkedWalletId => text().nullable().references(Wallets, #id)();
  TextColumn get notes => text().nullable()();
}

@DataClassName('ProfileEntry')
class Profiles extends Table with SyncableTable {
  TextColumn get username => text().withLength(min: 1, max: 64).withDefault(const Constant('David'))();
  TextColumn get fullName => text().withLength(min: 1, max: 128).withDefault(const Constant('David Arrozaqi'))();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get bio => text().nullable()();
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('IDR'))();
  RealColumn get monthlyIncomeTarget => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
