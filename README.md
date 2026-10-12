# fiBOnanci

> **High-Performance, Privacy-Centric, Offline-First Personal Finance & Smart Subscription Manager for Android.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Drift](https://img.shields.io/badge/Database-Drift%20(SQLite)-003B57)](https://drift.simonbinder.eu)
[![Tests](https://img.shields.io/badge/Tests-221%2F221%20Passed-7DF24E)](https://github.com)
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

### 5. Savings Pockets (`Kantong Tabungan`), Installments & 4-Pillar Financial Health
- **Savings Pockets (`Pockets`):** Goal-based and emergency vaults with atomic wallet-to-pocket transfers, isolated per-pocket mutation history, and stock-market-style spline trend charts (`1M`, `1B`, `1T`, `Semua`).
- **Installment & Subscription Tracker:** Supports both recurring bills (`monthly`, `yearly`, `weekly`) and fixed-tenor installment plans (`3x`, `6x`, `12x`, `Custom`) with cycle progress tracking and automatic completion rollover.
- **4-Pillar Financial Health Audit (`FinancialHealthService`):** Pure Dart engine scoring Emergency Runway, Fixed Commitment Ratio, Net Savings Margin, and Spend Pacing.
- **Multi-Profile Workspace (`Profiles`):** Independent financial workspaces (e.g., Personal, Business) with a 3D interactive profile card carousel.
---

## Technical Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Client Framework** | **Flutter (Dart 3.x)** | Cross-platform UI targeted to Android Native (API 26+) |
| **Local Database** | **Drift (SQLite 3)** | Type-safe reactive local storage with native C-bindings |
| **State Management** | **flutter_bloc** | Unidirectional data flow and reactive stream processing |
| **Native Integration** | **Kotlin `NotificationListenerService`** | Background notification ingestion bridge |
| **Typography** | **Plus Jakarta Sans** | Google Fonts with strict `FontFeature.tabularFigures()` |
| **Cloud Sync API (Planned)** | **Golang (Go 1.22+)** | Lightweight `/api/v1/sync` batch sync engine (LWW) |
| **Cloud Database (Planned)** | **Supabase (PostgreSQL 15+)** | Managed remote PostgreSQL storage |
| **Push Notifications (Planned)** | **FCM + `flutter_local_notifications`** | Dual-tier push engine (offline alarms + cloud reminders) |

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
│   ├── test/                         # Unit, BLoC & Widget test suites (43 files, 221 tests)
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
   *Expected output: All 221 tests passed!*

5. **Launch on Android device or emulator:**
   ```bash
   flutter run
   ```

6. **Grant Notification Access (for automatic bank transaction ingestion):**
   - On first launch, tap the **"Izinkan Akses Notifikasi"** banner on the Dashboard, or navigate to:
     `Android Settings > Apps & Notifications > Special App Access > Notification Access > fiBOnanci > Allow`.

---

## Testing & Quality Assurance

The codebase maintains strict automated test coverage across **43 test files (221 passing tests)** spanning all domain algorithms, Drift v6 database migrations, parsing pipelines, and UI interactions:

| Test Category | Key Suites | Coverage |
| :--- | :--- | :--- |
| **Domain & Math Engines** | `safe_to_spend_test.dart`, `cashflow_analytics_service_test.dart`, `financial_health_service_test.dart`, `rupiah_input_formatter_test.dart` | Safe-to-Spend math, 30-day cashflow & pocket trend series, 4-pillar health scoring, IDR formatting |
| **Notification Ingestion** | `notification_parser_test.dart`, `dynamic_notification_binding_test.dart`, `notification_account_routing_test.dart`, `pending_notification_inbox_test.dart` | 11+ Indonesian banks/e-wallets regex parsing, OTP/PIN hard-drop, SHA-256 deduplication, inbox swipe review |
| **Database & BLoC State** | `database_test.dart`, `pockets_database_test.dart`, `finance_bloc_test.dart`, `multi_profile_workspace_test.dart`, `profile_crud_test.dart`, `profile_handle_and_repair_test.dart` | Drift SQLite v6 schema, atomic balance reversals, pocket transfers, multi-profile isolation & auto-repair |
| **Tactile UI & Card Decks** | `wallet_deck_test.dart`, `wallet_fullscreen_details_test.dart`, `subscription_screen_test.dart`, `installment_and_slider_redesign_test.dart`, `expandable_modal_sheet_test.dart`, `empty_views_and_chart_visibility_test.dart` | 20 Swiss-modernist card themes, Hero transitions, installment tenor controls, cardless empty views, floating dock |
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
