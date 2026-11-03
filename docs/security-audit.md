---
status: critical-fail
tags: [security-audit, security]
project: "[[fibonanci]]"
audited_at: 2026-10-31
auditor: agent
severity_counts:
  critical: 1
  high: 3
  medium: 2
  low: 1
---

> **RULES FOR UPDATING THIS AUDIT NOTE:**
> *(These rules apply ONLY when writing to this file, not to coding or chatting)*
> 1. Note updates must be in strict English.
> 2. Maximize token efficiency: Be concise, use structured bullet points and tables, NO fluff.
> 3. Evidence required: Every reported vulnerability MUST cite exact file path, line numbers, and reproducible proof.
> 4. Keep status and severity counts synchronized with the Findings Matrix.

# Executive Summary

- **Final Verdict:** `CRITICAL FAIL`
- **Target Repository/Path:** `fiBOnanci/app` (Phase 7: Offline Scheduled Notifications & Auto-Deduct Engine)
- **Primary Tech Stack:** Flutter 3.x / Dart / Drift SQLite / Android API 26-34+ / flutter_local_notifications
- **Risk Overview:** Phase 7 implements local notification scheduling and automated recurring subscription auto-deductions. The implementation suffers from a critical concurrency race condition leading to double-deductions on app startup/resume, high-risk Google Play Store policy violations due to declaring `USE_EXACT_ALARM`, missing Android manifest broadcast receivers causing total loss of scheduled notifications upon device reboot, flawed billing cycle calculations resulting in monthly multi-billing of annual subscriptions, and lock-screen financial PII exposure.

| Metric | Count | Blockers | Resolved |
| :--- | :--- | :--- | :--- |
| **Critical** | 1 | 1 | 0 |
| **High** | 3 | 3 | 0 |
| **Medium** | 2 | 2 | 0 |
| **Low / Info** | 1 | 0 | 0 |

---

# Core Universal Checklist

Mandatory baseline checks for the audited codebase.

## 1. Secrets & Credential Exposure
- [x] `.gitignore` contains critical exclusions (`.env*`, `*.pem`, `*.key`, `*.jks`, `local.properties`)
- [x] No git-tracked secret files (`git ls-files | grep -E '\.env|\.pem|\.key'`)
- [x] Automated regex search shows zero hardcoded API keys, JWT secrets, passwords, or cloud tokens
- [x] Cloud provider credentials (AWS, GCP, Azure) absent from code and test fixtures
- [x] Commit history spot-checked for accidentally committed credentials

## 2. Dependency & Supply Chain Security (SCA)
- [x] Lockfile (`pubspec.lock`) tracked and cryptographic hashes verified for all dependencies
- [x] `flutter_local_notifications` (v22.3.3) and `timezone` (v0.11.2) evaluated; zero unpatched critical CVEs
- [x] Package sources resolve to official `https://pub.dev` TLS endpoints
- [x] No suspicious install hooks or malicious code injection vectors in dependencies

## 3. Environment & Configuration Hygiene
- [x] App is offline-first; no unauthenticated external network endpoints or cloud sync leakage
- [x] Local SQLite persistence encrypted with SQLCipher key derived via platform security vault
- [x] Error handling avoids leaking stack traces or database schema to end users
- [x] Android backup disabled (`android:allowBackup="false"`, `android:fullBackupContent="false"`)

## 4. Logging & Data Privacy
- [ ] **FAIL:** Cleartext financial amounts and recurring debt/bill titles rendered in notification bodies without private lockscreen visibility configuration (SEC-007)
- [x] No analytics or crash telemetry exfiltrating transaction or balance data to external servers
- [x] Notification listener service securely drops OTPs, PINs, and passwords via regex blacklist

---

# Modular Domain Extensions

## Module A: Web APIs & Backend Services
*N/A: fiBOnanci operates as an offline-first client application without external backend endpoints.*

## Module B: Web Frontend & SPAs
*N/A: Native Flutter mobile application targeting Android and iOS.*

## Module C: Mobile & IoT / Embedded Applications
- [x] **Client-Side Secret Isolation:** Zero backend API private keys or signing secrets embedded in APK
- [x] **Deep Links & IPC:** `FibonanciNotificationListener` secured with signature permission `android.permission.BIND_NOTIFICATION_LISTENER_SERVICE`
- [x] **Secure Local Storage:** Encrypted database via native SecurityVaultHelper
- [ ] **Android Permissions & Exact Alarms:** Declarations in `AndroidManifest.xml` violate Google Play Store exact alarm policies (SEC-002)
- [ ] **Device Lifecycle & Reboots:** Missing broadcast receivers cause scheduled alarms to disappear after reboot (SEC-003)

---

# Detailed Findings & Proof Matrix

### SEC-001: Race Condition & Double-Billing in SubscriptionAutoDeductRunner
- **Severity:** `CRITICAL`
- **Category:** Concurrency / Financial Double Billing
- **Status:** `[ ] Open`
- **Location:** `lib/domain/services/subscription_auto_deduct_runner.dart:26-62` and `lib/presentation/screens/main_shell.dart:65,72`
- **Description:** `SubscriptionAutoDeductRunner.runAutoDeduct` lacks a concurrency mutex or re-entrancy guard. It is dispatched asynchronously in both `_MainShellState.initState()` and `_MainShellState.didChangeAppLifecycleState(AppLifecycleState.resumed)`. On Android app startup or rapid app-resume sequences, both calls execute concurrently. Both invocations fetch the same active subscriptions from SQLite before either completes payment execution. Because `markSubscriptionAsPaid` does not perform cycle-level deduplication, both calls execute `markSubscriptionAsPaid(sub.id)`. The user's wallet is debited twice, duplicate expense transactions are logged, and `paidCycles` increments twice for a single billing cycle.

**Proof of Concept / Vulnerable Snippet:**
```dart
// lib/domain/services/subscription_auto_deduct_runner.dart:26-47
static Future<List<SubscriptionEntry>> runAutoDeduct({
  required AppDatabase db,
  DateTime? referenceDate,
  Function(SubscriptionEntry sub)? onDeducted,
}) async {
  // Concurrent call 1 & 2 both execute query simultaneously
  final activeSubs = await (db.select(db.subscriptions)
        ..where((t) =>
            t.isDeleted.equals(false) &
            t.status.equals('active') &
            t.autoDeduct.equals(true)))
      .get();

  for (final sub in activeSubs) {
    if (!isDueForAutoDeduct(sub, referenceDate: now)) continue;
    // Both calls invoke markSubscriptionAsPaid, debiting wallet balance twice!
    await db.markSubscriptionAsPaid(sub.id);
  }
}
```

**Remediation Plan / Unified Diff:**
```diff
--- a/lib/domain/services/subscription_auto_deduct_runner.dart
+++ b/lib/domain/services/subscription_auto_deduct_runner.dart
@@ -6,2 +6,3 @@
 class SubscriptionAutoDeductRunner {
+  static bool _isRunning = false;
@@ -30,2 +31,4 @@
   }) async {
+    if (_isRunning) return const [];
+    _isRunning = true;
     final now = referenceDate ?? DateTime.now();
+    try {
     final activeSubs = await (db.select(db.subscriptions)
@@ -58,3 +61,6 @@
       } catch (_) {}
     }
     return deducted;
+    } finally {
+      _isRunning = false;
+    }
```

**Verification Steps:**
- Automated Concurrency Test: Execute `await Future.wait([SubscriptionAutoDeductRunner.runAutoDeduct(db: db), SubscriptionAutoDeductRunner.runAutoDeduct(db: db)])` on an eligible subscription.
- Expected Result: Exactly 1 transaction created; wallet balance decremented by single cost; second runner returns empty list immediately.

---

### SEC-002: Google Play Policy Violation: Unjustified USE_EXACT_ALARM Declaration
- **Severity:** `HIGH`
- **Category:** Misconfiguration / Store Policy Compliance
- **Status:** `[ ] Open`
- **Location:** `android/app/src/main/AndroidManifest.xml:6`
- **Description:** `AndroidManifest.xml` explicitly declares `<uses-permission android:name="android.permission.USE_EXACT_ALARM" />`. Under Google Play Developer Policy (Android 13+ / 14+), `USE_EXACT_ALARM` is strictly restricted to apps whose core primary feature is an Alarm Clock, Timer, or Calendar. Personal finance, budgeting, and bill-reminder applications are categorically excluded. Submitting an application declaring `USE_EXACT_ALARM` without qualifying as a clock/calendar application triggers immediate rejection during Google Play review. Apps must instead use `SCHEDULE_EXACT_ALARM` (or inexact scheduling) with runtime permission verification.

**Proof of Concept / Vulnerable Snippet:**
```xml
<!-- android/app/src/main/AndroidManifest.xml:5-6 -->
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

**Remediation Plan / Unified Diff:**
```diff
--- a/android/app/src/main/AndroidManifest.xml
+++ b/android/app/src/main/AndroidManifest.xml
@@ -5,2 +5,1 @@
     <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
-    <uses-permission android:name="android.permission.USE_EXACT_ALARM" />
```

**Verification Steps:**
- Google Play Compliance Check: Verify `aapt dump permissions app/build/outputs/apk/release/app-release.apk` does not contain `android.permission.USE_EXACT_ALARM`.
- Policy Check: App conforms to Google Play Exact Alarm policy.

---

### SEC-003: Alarm Loss on Reboot via Missing Manifest Broadcast Receivers
- **Severity:** `HIGH`
- **Category:** Misconfiguration / Offline Reliability
- **Status:** `[ ] Open`
- **Location:** `android/app/src/main/AndroidManifest.xml:7`
- **Description:** `AndroidManifest.xml` requests `<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />`, but neither `ScheduledNotificationBootReceiver` nor `ScheduledNotificationReceiver` from `flutter_local_notifications` is registered within the `<application>` tag. When an Android device powers off or reboots, Android OS clears all pending alarms from `AlarmManager`. Without `ScheduledNotificationBootReceiver`, the `ACTION_BOOT_COMPLETED` broadcast is dropped, and all scheduled bill reminders are permanently wiped. Users never receive bill reminders unless they reopen the app.

**Proof of Concept / Vulnerable Snippet:**
```xml
<!-- android/app/src/main/AndroidManifest.xml:7 -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<!-- Lines 9-54: <application> contains NO receiver declarations for flutter_local_notifications -->
```

**Remediation Plan / Unified Diff:**
```diff
--- a/android/app/src/main/AndroidManifest.xml
+++ b/android/app/src/main/AndroidManifest.xml
@@ -53,2 +53,12 @@
         <meta-data
             android:name="flutterEmbedding"
             android:value="2" />
+        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
+            <intent-filter>
+                <action android:name="android.intent.action.BOOT_COMPLETED"/>
+                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
+            </intent-filter>
+        </receiver>
+        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
     </application>
```

**Verification Steps:**
- Shell test: Run `adb shell am broadcast -a android.intent.action.BOOT_COMPLETED -p com.fibonanci.app.fibonanci_app`.
- Expected Result: `ScheduledNotificationBootReceiver` receives broadcast; `flutter_local_notifications` reschedules stored alarms.

---

### SEC-004: Erroneous Multi-Billing of Yearly Subscriptions and Month-End Skip Flaw
- **Severity:** `HIGH`
- **Category:** Financial Business Logic Flaw
- **Status:** `[ ] Open`
- **Location:** `lib/domain/services/subscription_auto_deduct_runner.dart:17-23`
- **Description:** `SubscriptionAutoDeductRunner.isDueForAutoDeduct` evaluates whether a subscription was already paid using a naive monthly check: `sub.lastPaidDate!.year == now.year && sub.lastPaidDate!.month == now.month`.
  1. For `yearly` subscriptions: When paid in Month 1, Month 2 evaluates `lastPaidDate!.month == now.month` as `false`. As soon as `now.day >= sub.dueDay`, the runner charges the subscription again! An annual subscription is charged up to 12 times a year.
  2. For `weekly` subscriptions: Once paid on week 1 of a month, the month match evaluates to `true` for all remaining weeks, skipping auto-deduction for weeks 2, 3, and 4.
  3. For `dueDay == 31`: In 30-day months (Apr, Jun, Sep, Nov) and February (28/29 days), `now.day >= 31` never evaluates to true. Subscriptions due on the 31st are completely skipped on short months.

**Proof of Concept / Vulnerable Snippet:**
```dart
// lib/domain/services/subscription_auto_deduct_runner.dart:17-23
final isPaidThisCycle = sub.lastPaidDate != null &&
    sub.lastPaidDate!.year == now.year &&
    sub.lastPaidDate!.month == now.month;

if (isPaidThisCycle) return false;

return now.day >= sub.dueDay;
```

**Remediation Plan / Unified Diff:**
```diff
--- a/lib/domain/services/subscription_auto_deduct_runner.dart
+++ b/lib/domain/services/subscription_auto_deduct_runner.dart
@@ -17,7 +17,17 @@
-    final isPaidThisCycle = sub.lastPaidDate != null &&
-        sub.lastPaidDate!.year == now.year &&
-        sub.lastPaidDate!.month == now.month;
-
-    if (isPaidThisCycle) return false;
-
-    return now.day >= sub.dueDay;
+    if (sub.billingCycle == 'yearly') {
+      final isPaidThisYear = sub.lastPaidDate != null && sub.lastPaidDate!.year == now.year;
+      if (isPaidThisYear) return false;
+      return now.month >= 1 && now.day >= sub.dueDay;
+    } else if (sub.billingCycle == 'weekly') {
       if (sub.lastPaidDate != null && now.difference(sub.lastPaidDate!).inDays < 7) return false;
+      final targetWeekday = sub.dueDay.clamp(1, 7);
+      return now.weekday == targetWeekday;
+    } else {
+      final isPaidThisMonth = sub.lastPaidDate != null &&
+          sub.lastPaidDate!.year == now.year &&
+          sub.lastPaidDate!.month == now.month;
+      if (isPaidThisMonth) return false;
+      final maxDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
+      final effectiveDueDay = sub.dueDay.clamp(1, maxDaysInMonth);
+      return now.day >= effectiveDueDay;
+    }
```

**Verification Steps:**
- Unit Test: Pass a yearly subscription paid on 2026-01-10 to `isDueForAutoDeduct` with `referenceDate = 2026-02-15`.
- Expected Result: Returns `false`.
- Unit Test: Pass a monthly subscription with `dueDay = 31` to `isDueForAutoDeduct` with `referenceDate = 2026-04-30`.
- Expected Result: Returns `true` on the last day of the 30-day month.

---

### SEC-005: Missing Idempotency, Deleted & Completed Subscriptions Validation in markSubscriptionAsPaid
- **Severity:** `MEDIUM`
- **Category:** Data Integrity / Missing State Validation
- **Status:** `[ ] Open`
- **Location:** `lib/data/database/mutations/wallet_and_pocket_mutations.dart:65-110`
- **Description:** `markSubscriptionAsPaid` takes `subscriptionId` and directly logs a transaction and debits the wallet balance without validating whether:
  1. The subscription is soft-deleted (`sub.isDeleted == true`).
  2. The subscription is already completed (`sub.status == 'completed'`).
  3. The subscription cost is non-negative (`effectiveCost <= 0` can lead to negative expense, artificially inflating wallet balances).
  4. The subscription was already paid in the active billing period.

**Proof of Concept / Vulnerable Snippet:**
```dart
// lib/data/database/mutations/wallet_and_pocket_mutations.dart:67-75
final sub = await (select(subscriptions)..where((t) => t.id.equals(subscriptionId))).getSingle();
final now = DateTime.now().toUtc();
const uuid = Uuid();
final effectiveCost = (actualAmount != null && actualAmount >= 0) ? actualAmount : sub.cost;
// No check for sub.isDeleted or sub.status == 'completed'; proceeds to debit wallet!
```

**Remediation Plan / Unified Diff:**
```diff
--- a/lib/data/database/mutations/wallet_and_pocket_mutations.dart
+++ b/lib/data/database/mutations/wallet_and_pocket_mutations.dart
@@ -67,3 +67,6 @@
       final sub = await (select(subscriptions)..where((t) => t.id.equals(subscriptionId))).getSingle();
+      if (sub.isDeleted || sub.status == 'completed') return;
       final now = DateTime.now().toUtc();
       const uuid = Uuid();
-      final effectiveCost = (actualAmount != null && actualAmount >= 0) ? actualAmount : sub.cost;
+      final rawCost = (actualAmount != null && actualAmount > 0) ? actualAmount : sub.cost;
+      final effectiveCost = rawCost > 0 ? rawCost : 0.0;
+      if (effectiveCost <= 0) return;
```

**Verification Steps:**
- Unit Test: Attempt to call `markSubscriptionAsPaid` on a subscription with `status = 'completed'` and `isDeleted = true`.
- Expected Result: Method early-returns without modifying wallet balance or creating transaction.

---

### SEC-006: Battery Drain and AlarmManager DoS via Unthrottled Exact Alarm Synchronization
- **Severity:** `MEDIUM`
- **Category:** Resource Exhaustion / Battery Drain / DoS
- **Status:** `[ ] Open`
- **Location:** `lib/bloc/finance/finance_bloc.dart:120` and `lib/core/notifications/local_notification_service.dart:102-119, 135-146`
- **Description:** `FinanceBloc` listens to Drift stream `_SubscriptionsUpdated` and triggers `syncAllSubscriptionReminders` on every database emission. For $N$ active subscriptions, this triggers $3N$ cancel calls and $3N$ `zonedSchedule` calls configured with `AndroidScheduleMode.exactAllowWhileIdle`.
  1. `exactAllowWhileIdle` forces the Android kernel to wake the device from low-power Doze mode at microsecond precision. For non-critical reminders scheduled 3 days or 1 day in advance at 9:00 AM, waking from Doze mode causes measurable battery drain and triggers Android Vitals excessive wakeup warnings.
  2. Android 14+ denies exact alarm scheduling by default unless explicitly granted in Special App Access. If denied, calling `exactAllowWhileIdle` fails.
  3. Rescheduling every alarm on every subscription update generates excessive IPC with system `AlarmManager`.

**Proof of Concept / Vulnerable Snippet:**
```dart
// lib/core/notifications/local_notification_service.dart:117
androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

// lib/bloc/finance/finance_bloc.dart:120
on<_SubscriptionsUpdated>((event, emit) {
  emit(state.copyWith(subscriptions: event.subscriptions));
  LocalNotificationService.instance.syncAllSubscriptionReminders(event.subscriptions);
});
```

**Remediation Plan / Unified Diff:**
```diff
--- a/lib/core/notifications/local_notification_service.dart
+++ b/lib/core/notifications/local_notification_service.dart
@@ -117,1 +117,1 @@
-          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
+          androidScheduleMode: AndroidScheduleMode.inexact,
```

**Verification Steps:**
- Android Profiler Battery Test: Verify alarms do not trigger unbatched microsecond CPU wakeups during Doze mode; notifications appear within standard Android OS batching windows.

---

### SEC-007: Cleartext Financial and Debt PII Leakage on Lock Screen Notifications
- **Severity:** `LOW`
- **Category:** Data Privacy / PII Exposure
- **Status:** `[ ] Open`
- **Location:** `lib/core/notifications/local_notification_service.dart:107-116, 160-169`
- **Description:** `LocalNotificationService` creates notifications using `AndroidNotificationDetails` without configuring `visibility`. On Android devices, notifications default to public lockscreen visibility. The notification body prints exact monetary debts and bill names (`Tagihan Rp 15.000.000 akan jatuh tempo 3 hari lagi`, `Pembayaran Rp 2.500.000 telah otomatis dipotong`). Anyone with physical sight of the locked device can view the user's recurring expenses and loan/debt obligations. Setting `visibility: NotificationVisibility.private` ensures Android conceals sensitive text on secure lock screens while retaining the alert.

**Proof of Concept / Vulnerable Snippet:**
```dart
// lib/core/notifications/local_notification_service.dart:108-115
android: AndroidNotificationDetails(
  channelId,
  channelName,
  channelDescription: channelDescription,
  importance: Importance.high,
  priority: Priority.high,
  icon: '@mipmap/ic_launcher',
  // Missing visibility: NotificationVisibility.private
),
```

**Remediation Plan / Unified Diff:**
```diff
--- a/lib/core/notifications/local_notification_service.dart
+++ b/lib/core/notifications/local_notification_service.dart
@@ -115,2 +115,3 @@
               icon: '@mipmap/ic_launcher',
+              visibility: NotificationVisibility.private,
             ),
@@ -168,2 +169,3 @@
             icon: '@mipmap/ic_launcher',
+            visibility: NotificationVisibility.private,
           ),
```

**Verification Steps:**
- Device Verification: Trigger notification with locked phone; confirm lockscreen displays app icon and channel name while concealing cleartext financial amounts until biometric unlock.

---

# Remediation & Sign-off

- [ ] All `CRITICAL` and `HIGH` findings remediated and verified
- [ ] Automated regression test suite passes without regressions
- [ ] Negative security test case added to prevent vulnerability regression
- [ ] Dependencies updated and lockfile integrity verified
- [ ] Final verification scan executed

**Sign-off Record:**
- **Auditor Signature:** `SecurityAuditor (Adversarial Security Specialist)`
- **Completion Date:** 2026-10-31
- **Final Note:** Audit completed for Phase 7 (Offline Scheduled Notifications & Auto-Deduct Engine). 1 Critical, 3 High, 2 Medium, and 1 Low severity findings identified. System cannot achieve clean-pass until SEC-001 (double-billing race condition) and SEC-002 (Google Play policy violation) are patched.
