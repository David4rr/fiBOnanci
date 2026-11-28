import 'insight_models.dart';

const Map<SpendVelocity, List<String>> kEnInsightPhrases = {
  SpendVelocity.zeroSpend: [
    'Daily allocation intact, cash preserved cleanly without leaks.',
    'Full discipline today, your entire daily spending quota is saved.',
    'Calm cashflow today, daily balance ready to boost your savings.',
    'No spending today, your saving rhythm stays on track.',
    'Strong allocation defense, operational balance remains secure.',
  ],
  SpendVelocity.conservative: [
    'Very measured spending, most of today\'s quota is saved.',
    'Only essentials spent today, cashflow stays safely in the green.',
    'Proportional spending, remaining allocation pads tomorrow\'s budget.',
    'Neat expense control, daily savings keep growing.',
    'Smart spending today, remaining quota maintains cash stability.',
  ],
  SpendVelocity.moderate: [
    'Reasonable spending on plan, remaining quota keeps the rhythm.',
    'Daily cashflow is stable, spending stays within safe bounds.',
    'Controlled pace, resist impulse buys through tonight.',
    'Focused spending, enough allocation left for key needs.',
    'Balanced consumption, daily cash position remains solid.',
  ],
  SpendVelocity.nearLimit: [
    'Approaching daily cap, rest your wallet until tomorrow.',
    'Little allocation left, hold off non-essential buys tonight.',
    'Daily cap nearly reached, ease spending to keep your rhythm.',
    'Allocation margin is thin, prioritize essential needs only.',
    'Near daily threshold, protect remaining cash for tomorrow.',
  ],
  SpendVelocity.overLimit: [
    'Today\'s allocation exceeded. Pause spending and recover tomorrow.',
    'Spending exceeded quota. Keep tomorrow\'s pace tight for monthly balance.',
    'Over daily allocation today. Review expenses and tighten tomorrow.',
    'Daily limit crossed. Hold back flexible spending over the next days.',
    'Quota passed today. Lock your wallet and restore rhythm tomorrow.',
  ],
  SpendVelocity.deficit: [
    'Budget is in deficit. Prioritize essentials and pause extras.',
    'Cashflow is tight. Hold non-essential spending to recover.',
    'Protect reserve funds, cut outgoing spend until stabilized.',
    'Focus on liquidity recovery, pause all discretionary spending.',
  ],
};

const Map<MonthPhase, List<String>> kEnPhaseZeroSpend = {
  MonthPhase.early: [
    'Strong start to the month, daily allocation intact.',
    'Solid monthly opening, zero spend from today\'s quota.',
    'Organized early month, daily balance preserved cleanly.',
  ],
  MonthPhase.mid: [
    'Mid-month consistency held, cash reserves growing thicker.',
    'Calm mid-month pace, daily allocation remains untouched.',
    'Stable mid-month cashflow, saving discipline proven.',
  ],
  MonthPhase.latePhase: [
    'Late-month phase locked safely, cash surplus ready to save.',
    'Closing the month with high discipline, runway stays safe.',
    'Final days looking tight & safe, allocation defense locked surplus.',
  ],
};
