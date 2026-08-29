# fiBOnanci

> **High-Performance, Privacy-Centric, Offline-First Personal Finance & Smart Subscription Manager for Android.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Drift](https://img.shields.io/badge/Database-Drift%20(SQLite)-003B57)](https://drift.simonbinder.eu)
[![Tests](https://img.shields.io/badge/Tests-37%2F37%20Passed-7DF24E)](https://github.com)
[![Platform](https://img.shields.io/badge/Platform-Android%20(API%2026%2B)-3DDC84?logo=android&logoColor=white)](https://android.com)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Overview

Traditional personal finance applications suffer from cloud latency, forced online connectivity, and static monthly budget metrics that fail to reflect real spending capacity. 

**fiBOnanci** solves these friction points through a true **offline-first architecture**, an on-device **bank push notification parser**, and a mathematically grounded **Safe-to-Spend** budgeting engine. Every transaction, wallet mutation, and subscription schedule commits locally to SQLite in $<10\text{ ms}$ with instant UI reactivity and zero cloud dependency.

---

## Core Pillars & Architectural Highlights

### 1. Smart "Safe-to-Spend" Engine
Moves beyond arbitrary category limits by dynamically calculating real disposable income:

$$\text{Safe-to-Spend (Monthly)} = \text{Disposable Real Balance} - \text{Committed Pending Bills}$$

$$\text{Safe-to-Spend (Daily)} = \frac{\text{Safe-to-Spend (Monthly)}}{\max(1, \text{Days Remaining in Month})}$$

- **Flexible Source Selection:** Toggle between all accounts or isolate operational spending wallets (e.g., e-wallets and checking accounts only), ensuring dedicated savings vaults are never mixed into daily disposable allowances.
- **Dynamic Commitment Isolation:** Only recurring bills funded by selected spending accounts deduct from the budget; bills assigned to excluded savings accounts remain safely partitioned.
- **Instant Health Indicators:**
  - `Comfortable (Green)`: Buffer $\ge 30\%$ of disposable balance.
  - `Caution (Amber)`: Buffer between $0\%$ and $30\%$.
  - `Deficit Alert (Red)`: Upcoming bills exceed available liquid balance.

### 2. Automated On-Device Bank & E-Wallet Ingestion
Intercepts incoming financial push notifications in real-time via Android native `NotificationListenerService`:
- **Supported Providers (Indonesian Ecosystem):**
  - Conventional Banks: **BCA**, **Bank Mandiri**, **BRI**, **BNI**
  - Digital Banks: **blu by BCA Digital**, **SeaBank**, **Bank Jago**
  - E-Wallets: **GoPay**, **OVO**, **DANA**, **ShopeePay**
- **Zero Cloud Leakage:** 100% on-device deterministic regex parsing. Raw notification payloads are processed in-memory and never written to disk or sent to remote servers.
- **Strict OTP/2FA Blacklist:** Pre-parser regex guard drops any notification matching sensitive tokens (`otp`, `pin`, `kode`, `verifikasi`, `password`, `token`) immediately.
- **SHA-256 Deduplication Window:** Guards against double-entry when financial apps emit dual alerts (e.g., push notification + in-app toast).

### 3. True Offline-First with Drift SQLite
- Built on **Drift ORM** using native C-bindings (`sqlite3`).
- **Reactive UI Streams:** Mutations emit immediately; BLoC updates RAM state and repaints UI in $<10\text{ ms}$.
- **Client-Side UUIDv4 Primary Keys:** Zero auto-increment ID collisions during offline multi-device usage.
- **Deterministic Two-Way Sync:** Metadata columns (`created_at`, `updated_at`, `is_synced`, `is_deleted`) support atomic batch synchronization via Last-Write-Wins (LWW) conflict resolution against a cloud backend.

### 4. Tactile Folder-Tab & Acrylic Frosted Glass UI
- **Design System:** "Tactile Folder-Tab Dark Mode" on a deep matte obsidian canvas (`#0C0D11`) paired with vibrant neo-pastel accents:
  - Neo-Chartreuse (`#D4F442`) &mdash; Safe-to-Spend
  - Neo-Mint (`#7DF24E`) &mdash; Verified Liquidity
  - Neo-Coral (`#FF7052`) &mdash; Pending Commitments & Expenses
  - Neo-Cyan (`#26D9D9`) &mdash; Transfers & Daily Allowance
- **Interactive Stacked Waterfall Card Deck:** Uniform peeking folder tabs for resting accounts, standalone elevated ATM card focus view on tap with zero duplicate elements.
- **Translucent Acrylic Bottom Nav Dock:** Floating dual-pod capsule with geometric `PodClipper`, lightweight `BackdropFilter` (sigma 16), and semi-transparent obsidian glass fill.
- **30-Day Dual-Series Spline Charts:** Native cubic Bezier line charts rendered via `CustomPainter` plotting income (green) and expense (red) curves over a 30-day timeline with shared scale normalization.

---

## Technical Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Client Framework** | **Flutter (Dart 3.x)** | Cross-platform UI targeted to Android Native (API 26+) |
| **Local Database** | **Drift (SQLite 3)** | Type-safe reactive local storage with native C-bindings |
| **State Management** | **flutter_bloc** | Unidirectional data flow and reactive stream processing |
| **Native Integration** | **Kotlin `NotificationListenerService`** | Background notification ingestion bridge |
| **Typography** | **Plus Jakarta Sans** | Google Fonts with strict `FontFeature.tabularFigures()` |
| **Cloud Sync API** | **Golang (Go 1.22+)** | Lightweight `/api/v1/sync` batch sync engine (LWW) |
| **Cloud Database** | **Supabase (PostgreSQL 15+)** | Managed remote PostgreSQL storage |
| **Push Notifications** | **FCM + `flutter_local_notifications`** | Dual-tier push engine (offline alarms + cloud reminders) |

---

## Project Structure

```text
fiBOnanci/
├── app/
│   ├── lib/
│   │   ├── bloc/
│   │   │   └── finance/              # FinanceBloc, Events & State
│   │   ├── core/
│   │   │   ├── native_bridge/        # Android NotificationListener MethodChannel
│   │   │   └── notification_parser/  # Regex parsing pipeline & security guards
│   │   ├── data/
│   │   │   ├── database/             # Drift SQLite database, schema & DAOs
│   │   │   └── repositories/         # DriftFinanceRepository implementation
│   │   ├── domain/
│   │   │   └── services/             # SafeToSpendService mathematical engine
│   │   └── presentation/
│   │       ├── screens/              # Dashboard, Wallets, Subscriptions, MainShell
│   │       ├── theme/                # AppColors, AppTypography, AppTheme
│   │       └── widgets/              # FolderTabCard, BottomNavDock, TrendSplineChart
│   ├── test/                         # Unit, BLoC & Widget test suites (37 tests)
│   └── android/                      # Native Android project with Kotlin service
└── README.md
```

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `^3.24.0` (Dart `^3.5.0`)
- **Android SDK**: `API Level 26+` (Android 8.0 Oreo or higher)
- **Java**: JDK 17+

### Installation & Run

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/fiBOnanci.git
   cd fiBOnanci/app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run database code generation (if Drift schema modified):**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Execute test suite:**
   ```bash
   flutter test
   ```
   *Expected output: All 37 tests passed!*

5. **Launch on Android device or emulator:**
   ```bash
   flutter run
   ```

6. **Grant Notification Access (for automatic bank transaction ingestion):**
   - On first launch, tap the **"Izinkan Akses Notifikasi"** banner on the Dashboard, or navigate to:
     `Android Settings > Apps & Notifications > Special App Access > Notification Access > fiBOnanci > Allow`.

---

## Testing & Quality Assurance

The codebase maintains strict automated test coverage across all domain algorithms, parsing pipelines, and UI interactions:

| Test Suite | Description | Test Count |
| :--- | :--- | :--- |
| `notification_parser_test.dart` | Indonesian bank & e-wallet push parsing and security guards (OTP rejection) | 16 tests |
| `safe_to_spend_test.dart` | Mathematical verification of Safe-to-Spend and flexible spending sources | 4 tests |
| `finance_bloc_test.dart` | BLoC reactive mutations, state transitions, and in-memory Safe-to-Spend recalculation | 3 tests |
| `database_test.dart` | Drift SQLite seeds, atomic balance debits/credits, and inter-wallet transfers | 3 tests |
| `wallet_deck_test.dart` | Stacked card deck navigation, 30-day dual charts, in-place lift, and balance edits | 2 tests |
| `safe_to_spend_selection_widget_test.dart` | Dashboard Safe-to-Spend modal interaction and live source account filtering | 1 test |
| `full_feature_flow_test.dart` | End-to-end integration flow across transactions, subscriptions, and balances | 1 test |
| `history_tap_test.dart` | Transaction detail modal and wallet reassignment verification | 1 test |
| `design_system_test.dart` | Component-level verification of `FolderTabCard` and `OverlappingDeckItem` | 2 tests |
| `widget_test.dart` | App smoke test and screen navigation dock verification | 1 test |

Run the full suite with:
```bash
flutter test
```

---

## Security & Privacy Guarantees

1. **Local Execution**: All financial balances, transactions, and notification payloads reside strictly on your local device.
2. **Credential Sanitization**: The regex pipeline actively checks incoming pushes against token blacklists and immediately drops authentication credentials, PIN change notices, and verification codes.
3. **Soft-Deletion Propagation**: Entities marked for deletion are never dropped abruptly while offline, preventing sync anomalies when reconciling with cloud backends.

---

## License

Distributed under the **MIT License**. See `LICENSE` for more information.
