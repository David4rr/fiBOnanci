# Repository Guidelines

## Project Overview

**fiBOnanci** is an offline-first personal finance and smart subscription management mobile application for Android (API 26+), built with Flutter and Dart. Its primary architectural goal is zero-latency (<10 ms), privacy-preserving on-device financial tracking and disposable income intelligence without requiring cloud services or external servers.

### Core Value Proposition & Mechanics
- **Dynamic Safe-to-Spend Engine**: Calculates true monthly disposable income (`Total Real Balance - Committed Pending Bills`) and daily burn allowance (`Monthly Safe-to-Spend / Days Remaining`) with flexible wallet isolation (e.g., excluding savings vaults from operational spend) and tri-color health indicators (`comfortable`, `caution`, `deficit`).
- **On-Device Push Ingestion**: Intercepts notifications from Indonesian banking apps and digital wallets via native Android `NotificationListenerService`. Parses transactions on-device using deterministic regex with a mandatory security blacklist (hard-dropping OTPs, PINs, passwords, and promo texts) and SHA-256 deduplication windows.
- **Tactile Obsidian & Frosted Glass UI**: Custom design system built on a deep obsidian canvas (`#0C0D11`) with neo-pastel accents, featuring a 2x2 Bento grid, stacked ATM-style wallet card deck with cubic Bezier 30-day spline charts, and an acrylic floating bottom navigation dock.

---

## Architecture & Data Flow

The codebase strictly follows **Clean Architecture** principles combined with the **BLoC pattern** (`flutter_bloc`), the **Repository pattern**, and **Drift SQLite** local persistence.

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   (Screens, Bento Grids, Card Decks, Modals, Themes)   │
└────────────────────────▲──────┬────────────────────────┘
                         │      │ Dispatch UI Events
            BlocBuilder  │      │ (AddTransactionEvent, etc.)
            State Stream │      ▼
┌────────────────────────┴───────────────────────────────┐
│              BLoC Layer (FinanceBloc)                  │
│   (FinanceState, Internal Reactive Stream Handlers)    │
└────────────────────────▲──────┬────────────────────────┘
                         │      │ Calls Repository
         Internal Events │      │ (addTransaction, etc.)
      (_WalletsUpdated)  │      ▼
┌────────────────────────┴───────────────────────────────┐
│     Domain Services (Pure Dart Math & Analytics)       │
│  - SafeToSpendService.calculate()                      │
│  - CashflowAnalyticsService.calculateMonthlyCashflow() │
└────────────────────────▲──────┬────────────────────────┘
                         │      │ Delegated Write
          Stream Watchers│      ▼
┌────────────────────────┴───────────────────────────────┐
│        Repository Layer (DriftFinanceRepository)       │
└────────────────────────▲──────┬────────────────────────┘
                         │      │ Atomic Transactions
          Reactive Watch │      │ (logTransactionWithBalance)
                         │      ▼
┌────────────────────────────────────────────────────────┐
│         Database Layer (AppDatabase - Drift ORM)       │
│         - SQLite 3 background native database          │
│         - Syncable tables: Wallets, Transactions, etc. │
└────────────────────────▲───────────────────────────────┘
                         │
                 Auto-Logged Notifications
                         │
┌────────────────────────┴───────────────────────────────┐
│     Native Platform Bridge (NotificationBridge)        │
│  - EventChannel: com.fibonanci.app/live_notifications  │
│  - MethodChannel: com.fibonanci.app/notification_serv  │
│  - On-Device Parsing: NotificationParser               │
└────────────────────────┘
```

### Data Flow Lifecycle
1. **User Action / Push Event**: The UI emits a public `FinanceEvent` via `context.read<FinanceBloc>().add(...)`, or the native Android listener captures a notification and delivers it via `EventChannel` to `NotificationBridge`.
2. **Repository Delegation**: `FinanceBloc` delegates mutations to `FinanceRepository` (`DriftFinanceRepository`).
3. **Atomic SQLite Execution**: `AppDatabase` executes writes inside `transaction(() async { ... })`, mutating ledger records and updating wallet balances atomically.
4. **Reactive Drift Watchers**: Active queries (`watchWallets()`, `watchRecentTransactions()`, etc.) emit updated record sets from the background isolate.
5. **Internal BLoC Ingestion & Domain Recalculation**: `FinanceBloc` receives private stream events (`_WalletsUpdated`, `_TransactionsUpdated`), feeds fresh data to pure static domain services (`SafeToSpendService.calculate()`, `CashflowAnalyticsService.calculateMonthlyCashflow()`), and emits a refreshed `FinanceState`.
6. **Synchronous UI Re-render**: `BlocBuilder` updates widgets without main-thread disk I/O.

---

## Key Directories

```
lib/
├── bloc/finance/            # Central state management (FinanceBloc, FinanceEvent, FinanceState)
├── core/
│   ├── formatters/          # Rupiah dynamic input and display formatters
│   ├── native_bridge/       # Android MethodChannel & EventChannel communication
│   └── notification_parser/ # Regex parser engine, security filter, and data models
├── data/
│   ├── database/            # Drift SQLite database setup, isolates, and mutations
│   │   └── tables/          # Schema table declarations & SyncableTable mixin
│   └── repositories/        # Abstract and concrete repository implementations
├── domain/services/         # Pure Dart mathematical engines (Safe-to-Spend, Cashflow)
└── presentation/
    ├── modals/              # Bottom sheets (Add Wallet, Safe-to-Spend, Filters, Edit)
    ├── screens/             # Primary scaffold views (MainShell, Dashboard, Wallet, Subscriptions)
    ├── theme/               # Design tokens (AppColors, AppTypography)
    └── widgets/             # Reusable UI components (BentoGrid, FolderTabCard, CardDeck, Dock)
test/                        # Unit, BLoC, database integration, and widget tests
android/app/src/main/kotlin/ # Android Kotlin service and platform channels
```

---

## Development Commands

Run all shell commands through `rtk` where applicable.

### Dependency Management & Setup
```bash
# Fetch dependencies
flutter pub get

# Check outdated dependencies
flutter pub outdated
```

### Drift Code Generation (`build_runner`)
When modifying `lib/data/database/tables/tables.dart` or `app_database.dart`, re-generate `app_database.g.dart`:
```bash
# Run code generation once (deletes stale outputs)
dart run build_runner build --delete-conflicting-outputs

# Continuous watch during database development
dart run build_runner watch --delete-conflicting-outputs

# Clean generated artifacts
dart run build_runner clean
```

### Static Analysis & Linting
```bash
# Run static analyzer
flutter analyze
```

### Running Tests
```bash
# Run all test suites
flutter test

# Run a specific test file
flutter test test/database_test.dart

# Run tests matching a name pattern
flutter test --name "SafeToSpendService"

# Run tests with coverage output
flutter test --coverage
```

### Running & Building Application
```bash
# Launch debug build on connected Android device/emulator
flutter run -d android

# Build release APK
flutter build apk --release

# Build split ABI APKs (reduced download size)
flutter build apk --split-per-abi

# Build Google Play App Bundle
flutter build appbundle
```

---

## Code Conventions & Common Patterns

### Naming Conventions
- **Files & Directories**: Always `snake_case.dart` (e.g., `safe_to_spend_service.dart`).
- **Classes, Enums, Mixins**: `PascalCase` (e.g., `FinanceBloc`, `FolderTabCard`).
- **Variables, Functions, Getters**: `camelCase` (e.g., `safeToSpendMonthly`, `calculateMonthlyCashflow`).
- **Internal / Private Members & Events**: Prefix with underscore `_` (e.g., `_WalletsUpdated`, `_initStreamListeners`).
- **Constants**: Static const in dedicated token classes (e.g., `AppColors.neoChartreuse`, `AppTypography.headingLg`).

### State Management Patterns (`FinanceBloc`)
- **Single Source of Truth**: All UI state resides in `FinanceState`. State updates must use `copyWith(...)`.
- **Structural Immutability**: `FinanceState` implements value equality using `operator ==` and `hashCode` with `listEquals` and `setEquals`.
- **Automatic Metrics Re-computation**: Domain calculations are invoked inside the state constructor and `copyWith()` fallback defaults, guaranteeing metrics are never stale.
- **Separation of Events**:
  - *Public UI commands*: `AddTransactionEvent`, `UpdateTransactionEvent`, `DeleteTransactionEvent`, `AddSubscriptionEvent`, `MarkSubscriptionPaidEvent`, `SetSafeToSpendWalletsEvent`.
  - *Private database sync events*: `_WalletsUpdated`, `_CategoriesUpdated`, `_TransactionsUpdated`, `_SubscriptionsUpdated`.
- **Safe Modal Reads**: Modals read data synchronously from memory via `context.read<FinanceBloc>().state` to achieve 0 ms sheet rendering.

### Database & Ledger Mutability (`AppDatabase`)
- **Client-Side UUIDv4 Primary Keys**: Never use auto-incrementing integer IDs. All tables use `SyncableTable` mixin providing `id = text()()`, `createdAt`, `updatedAt`, `isSynced`, and `isDeleted`.
- **Soft Deletions**: Never execute raw `DELETE FROM` statements. Set `isDeleted = true` so records can synchronize with remote servers via Last-Write-Wins (LWW).
- **Atomic Balance Updates**: Any ledger entry mutation must be wrapped in `transaction(() async { ... })`:
  - `logTransactionWithBalanceMutation()`: Inserts transaction, mutates source wallet (expense/transfer) and target wallet (income/transfer).
  - `updateTransactionWithWalletReassignment()`: Reverts old transaction amount from former wallet and applies new amount to new wallet.
  - `deleteTransactionWithBalanceReversal()`: Soft-deletes transaction and reverses financial effect.
  - `markSubscriptionAsPaid()`: Records subscription payment date and logs an atomic expense transaction.

### Pure Domain Calculation Pattern
- Services under `lib/domain/services/` (`SafeToSpendService`, `CashflowAnalyticsService`) must remain **pure Dart**: no Flutter widget imports, no context, no database connections.
- Pass an explicit `referenceDate: DateTime` parameter to date-sensitive methods to allow deterministic testing without clock drift.

### Design System & Component Patterns
- **Tabular Figures for Currencies**: Always apply `FontFeature.tabularFigures()` on currency displays (`AppTypography.tabularFigures`) to prevent number-shifting during animations.
- **Card Stacks**: In `WalletCardDeck`, when a card is selected or expanded, replace its deck placeholder with `const SizedBox.shrink()` to prevent visual duplicates.
- **Custom Clippers**: Asymmetric folder tabs use `FolderTabClipper` (`folder_tab_card.dart`) with bezier curves; frosted docks use `PodClipper` (`bottom_nav_dock.dart`).

---

## Important Files

| File Path | Description |
|---|---|
| `lib/main.dart` | Application entry point: initializes `id_ID` locale, instantiates `AppDatabase`, provides root `FinanceBloc`, and mounts `FiBOnanciApp`. |
| `pubspec.yaml` | Project dependencies (`drift`, `flutter_bloc`, `google_fonts`, `intl`, `uuid`), Dart SDK constraints, and build runners. |
| `analysis_options.yaml` | Static analysis configuration extending `package:flutter_lints/flutter.yaml`. |
| `lib/bloc/finance/finance_bloc.dart` | Central reactive BLoC managing Drift streams, UI events, and domain recalculations. |
| `lib/bloc/finance/finance_state.dart` | Immutable application state holding entities, calculated metrics, and filters. |
| `lib/data/database/app_database.dart` | Drift SQLite database definition, isolate configuration, migrations, seed data, and atomic transaction methods. |
| `lib/data/database/tables/tables.dart` | Drift table declarations (`Wallets`, `Categories`, `Transactions`, `Subscriptions`, `NotificationRules`) with `SyncableTable`. |
| `lib/data/database/app_database.g.dart` | Generated Drift ORM code, data classes (`WalletEntry`, `TransactionEntry`), and companions. |
| `lib/data/repositories/finance_repository.dart` | Interface and Drift repository implementation exposing reactive query streams. |
| `lib/domain/services/safe_to_spend_service.dart` | Pure domain service computing real balance, pending commitments, daily pacing, and health status. |
| `lib/domain/services/cashflow_analytics_service.dart` | Pure domain service for 30-day cashflow aggregation and transaction search/filtering. |
| `lib/core/native_bridge/notification_bridge.dart` | Platform bridge for Android `MethodChannel` and `EventChannel` notifications. |
| `lib/core/notification_parser/notification_parser.dart` | 3-stage regex parser for 8+ Indonesian banks with security blacklist and SHA-256 deduplication. |
| `lib/presentation/screens/main_shell.dart` | Root navigation shell hosting Dashboard, Wallets, Subscriptions, and floating bottom dock. |
| `android/app/src/main/kotlin/.../FibonanciNotificationListener.kt` | Native Android service intercepting push notifications from banking apps. |

---

## Runtime & Tooling Preferences

- **Dart SDK**: `^3.11.5`
- **Flutter SDK**: `stable` channel
- **Package Manager**: `flutter pub` (Dart pub)
- **Java / JVM**: Java 17 (`JavaVersion.VERSION_17`, Kotlin `jvmTarget = "17"`)
- **Gradle**: `8.14` (`gradle-wrapper.properties`)
- **Android Gradle Plugin (AGP)**: `8.11.1`
- **Kotlin**: `2.2.20`
- **Android SDK Requirements**:
  - `minSdk`: API 26 (Android 8.0 Oreo) — required by `NotificationListenerService` and modern notification channels.
  - `compileSdk` / `targetSdk`: Set dynamically via `flutter.compileSdkVersion` and `flutter.targetSdkVersion`.
- **Tooling Constraints**:
  - Code generation via `build_runner` and `drift_dev` is strictly required whenever table definitions or database queries change.
  - Fonts are loaded dynamically via `google_fonts` (`Plus Jakarta Sans`); do not add static `.ttf` font assets to `pubspec.yaml` unless offline font packaging is explicitly requested.
  - All persistence is native SQLite via `sqlite3_flutter_libs`; no external network servers or cloud endpoints are used.

---

## Testing & QA

### Testing Frameworks & Philosophy
- **Framework**: Native `flutter_test` (Flutter SDK). Note that `bloc_test` is not included in `pubspec.yaml`; BLoC tests use standard Dart `Stream` assertions (`expectLater`, `emitsThrough`, `firstWhere`).
- **Zero Mocking for Database**: Tests run against real in-memory Drift SQLite instances (`NativeDatabase.memory()`). This guarantees 100% parity with production SQL constraints, default seeding, and foreign key cascades without brittle mocks.

### Standard Test Patterns

#### 1. In-Memory Database & Repository Setup
```dart
late AppDatabase database;
late DriftFinanceRepository repository;

setUp(() {
  database = AppDatabase(NativeDatabase.memory());
  repository = DriftFinanceRepository(database);
});

tearDown(() async {
  await database.close();
});
```

#### 2. Reactive BLoC Testing via Stream Expectations
```dart
test('emits success state when LoadFinanceData is dispatched', () async {
  final bloc = FinanceBloc(repository: repository);
  addTearDown(bloc.close);

  bloc.add(const LoadFinanceData());

  await expectLater(
    bloc.stream,
    emitsThrough(predicate<FinanceState>((s) => s.status == FinanceStatus.success)),
  );
});
```

#### 3. Pure Domain Testing with Fixed Dates
```dart
test('calculates safe to spend with fixed reference date', () {
  final result = SafeToSpendService.calculate(
    wallets: mockWallets,
    subscriptions: mockSubscriptions,
    referenceDate: DateTime(2026, 8, 28),
  );

  expect(result.healthStatus, HealthStatus.comfortable);
});
```

#### 4. Widget Tests with Indonesian Locale & Mobile Viewport
```dart
setUpAll(() {
  initializeDateFormatting('id_ID', null);
});

testWidgets('renders dashboard correctly', (tester) async {
  tester.view.physicalSize = const Size(400 * 2, 900 * 2);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    FiBOnanciApp(database: database, repository: repository),
  );
  await tester.pumpAndSettle();

  expect(find.text('Safe-to-Spend'), findsOneWidget);
});
```

### Test Suite Inventory
The test suite consists of 12 test files covering all architectural layers:
- `test/cashflow_analytics_service_test.dart`: Monthly aggregation, 30-day series, and filtering.
- `test/safe_to_spend_test.dart`: Safe-to-spend math, financial health thresholds, and wallet isolation.
- `test/rupiah_input_formatter_test.dart`: Real-time Indonesian dot formatting and currency parsing.
- `test/notification_parser_test.dart`: Regex accuracy for 8+ banks/e-wallets, OTP/promo dropping, and deduplication.
- `test/finance_bloc_test.dart`: BLoC stream lifecycle, reactive updates, and account filtering.
- `test/database_test.dart`: Drift SQLite schema verification, atomic mutations, and balance reversals.
- `test/full_feature_flow_test.dart`: End-to-end user journey (balance setup -> expense -> subscription -> push notification).
- `test/design_system_test.dart`: Visual clipping of `FolderTabCard` and `OverlappingDeckItem`.
- `test/widget_test.dart`: Smoke test for app scaffold, dock, and navigation tabs.
- `test/wallet_deck_test.dart`: Interactive card deck, card lifting, and balance sheet modal.
- `test/safe_to_spend_selection_widget_test.dart`: Interactive account selection modal and recalculation.
- `test/history_tap_test.dart`: Transaction tap-to-edit interactions and wallet reassignment.
