part 'events/transaction_events.dart';
part 'events/subscription_events.dart';
part 'events/wallet_events.dart';
part 'events/pocket_events.dart';
part 'events/profile_events.dart';

abstract class FinanceEvent {
  const FinanceEvent();
}

class LoadFinanceData extends FinanceEvent {
  const LoadFinanceData();
}
