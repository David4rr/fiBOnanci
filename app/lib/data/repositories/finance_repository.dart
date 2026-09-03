import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../../core/native_bridge/notification_bridge.dart';
import 'i_finance_repository.dart';

export 'i_finance_repository.dart';

part 'drift/drift_repo_base.dart';
part 'drift/drift_transaction_repository.dart';
part 'drift/drift_wallet_repository.dart';
part 'drift/drift_subscription_repository.dart';
part 'drift/drift_pocket_repository.dart';
part 'drift/drift_profile_repository.dart';

class DriftFinanceRepository extends DriftRepoBase
    with
        DriftTransactionRepository,
        DriftWalletRepository,
        DriftSubscriptionRepository,
        DriftPocketRepository,
        DriftProfileRepository
    implements FinanceRepository {
  @override
  final AppDatabase db;
  static const _uuid = Uuid();
  @override
  Uuid get uuid => _uuid;

  DriftFinanceRepository(this.db);
}
