import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/finance/finance_bloc.dart';
import 'rupiah_input_formatter.dart';

/// Custom [NumberFormat] that non-destructively converts base IDR values
/// into the target currency using [AppCurrency.rateFor] before formatting.
class ConvertedCurrencyFormat implements NumberFormat {
  final String code;
  final String signPrefix;
  final NumberFormat _intFormat;
  final NumberFormat _decFormat;

  ConvertedCurrencyFormat({
    required this.code,
    this.signPrefix = '',
  }) : _intFormat = NumberFormat.currency(
         locale: 'id_ID',
         symbol: '$signPrefix${AppCurrency.symbolFor(code)}',
         decimalDigits: 0,
       ),
       _decFormat = NumberFormat.currency(
         locale: 'id_ID',
         symbol: '$signPrefix${AppCurrency.symbolFor(code)}',
         decimalDigits: 2,
       );

  @override
  String get currencySymbol => _intFormat.currencySymbol;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
  @override
  String format(dynamic number) {
    if (number is! num) return _intFormat.format(number);
    final converted = AppCurrency.fromBaseIdr(number.toDouble(), code);
    final isWhole = (converted - converted.roundToDouble()).abs() < 0.005;
    if (code == 'IDR' || code == 'JPY' || isWhole) {
      return _intFormat.format(converted.roundToDouble());
    }
    return _decFormat.format(converted);
  }
}

/// Centralized currency symbol, offline exchange rate, & formatter resolver.
/// All database records remain stored in base IDR to prevent rounding drift.
class AppCurrency {
  AppCurrency._();

  static const Map<String, String> _symbols = {
    'IDR': 'Rp ',
    'USD': r'$ ',
    'EUR': '€ ',
    'SGD': r'S$ ',
    'MYR': 'RM ',
    'JPY': '¥ ',
  };

  /// Default offline benchmark rates (1 unit of currency = X IDR).
  static const Map<String, double> defaultRatesToIdr = {
    'IDR': 1.0,
    'USD': 16000.0,
    'EUR': 17500.0,
    'SGD': 12000.0,
    'MYR': 3600.0,
    'JPY': 105.0,
  };

  static final Map<String, double> _ratesToIdr = Map.of(defaultRatesToIdr);
  static final Map<String, ConvertedCurrencyFormat> _cache = {};
  static bool isLiveRate = false;

  static String _norm([String? code]) => (code ?? 'IDR').trim().toUpperCase();

  static String symbolFor([String? code]) {
    final c = _norm(code);
    return _symbols[c] ?? '$c ';
  }

  static double rateFor([String? code]) => _ratesToIdr[_norm(code)] ?? 1.0;

  static void setRate(String code, double idrPerUnit) {
    final c = _norm(code);
    if (c == 'IDR' || idrPerUnit <= 0) return;
    _ratesToIdr[c] = idrPerUnit;
    isLiveRate = false;
    _cache.clear();
  }

  static void resetRates() {
    _ratesToIdr..clear()..addAll(defaultRatesToIdr);
    isLiveRate = false;
    _cache.clear();
  }

  /// Fetches live market exchange rates against IDR; silently keeps cached/offline rates if offline.
  static Future<bool> syncLiveRates() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      final req = await client.getUrl(Uri.parse('https://open.er-api.com/v6/latest/IDR'));
      final res = await req.close().timeout(const Duration(seconds: 4));
      if (res.statusCode != 200) return false;
      final decoded = jsonDecode(await res.transform(utf8.decoder).join()) as Map<String, dynamic>;
      final rates = decoded['rates'] as Map<String, dynamic>?;
      if (rates == null) return false;
      for (final code in defaultRatesToIdr.keys) {
        final perIdr = (rates[code] as num?)?.toDouble();
        if (code != 'IDR' && perIdr != null && perIdr > 0) {
          _ratesToIdr[code] = (1.0 / perIdr).roundToDouble();
        }
      }
      isLiveRate = true;
      _cache.clear();
      return true;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  static double fromBaseIdr(double idrAmount, [String? code]) {
    final rate = rateFor(code);
    return rate <= 0 ? idrAmount : idrAmount / rate;
  }

  static double toBaseIdr(double amountInCurrency, [String? code]) =>
      amountInCurrency * rateFor(code);

  static String formatIdrForInput(double idrAmount, [String? code]) =>
      RupiahInputFormatter.format(fromBaseIdr(idrAmount, code).roundToDouble());

  static double parseInputToIdr(String text, [String? code]) =>
      toBaseIdr(RupiahInputFormatter.parse(text), code);

  static String formatInputOf(BuildContext context, double idrAmount) =>
      formatIdrForInput(idrAmount, codeOf(context, listen: false));

  static double parseInputOf(BuildContext context, String text) =>
      parseInputToIdr(text, codeOf(context, listen: false));

  static NumberFormat forCode([String? code, String signPrefix = '']) {
    final c = _norm(code);
    return _cache.putIfAbsent('$signPrefix|$c', () => ConvertedCurrencyFormat(code: c, signPrefix: signPrefix));
  }

  static String codeOf(BuildContext context, {bool listen = true}) {
    try {
      return BlocProvider.of<FinanceBloc>(context, listen: listen).state.profile.currency;
    } catch (_) {
      return 'IDR';
    }
  }

  static String symbolOf(BuildContext context, {bool listen = true}) =>
      symbolFor(codeOf(context, listen: listen));

  static NumberFormat of(BuildContext context, {bool listen = true, String signPrefix = ''}) =>
      forCode(codeOf(context, listen: listen), signPrefix);

  static NumberFormat read(BuildContext context, {String signPrefix = ''}) =>
      of(context, listen: false, signPrefix: signPrefix);
  /// Formats compact values (Jt / Rb / k / M) after converting from base IDR.
  static String formatCompact(double idrVal, [String? code]) {
    final c = _norm(code);
    final sym = symbolFor(c);
    final val = fromBaseIdr(idrVal, c);
    if (c == 'IDR') {
      if (val >= 1000000) return '$sym${(val / 1000000).toStringAsFixed(1)} Jt';
      if (val >= 1000) return '$sym${(val / 1000).toStringAsFixed(0)} Rb';
      return '$sym${val.toStringAsFixed(0)}';
    }
    if (val >= 1000000) return '$sym${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '$sym${(val / 1000).toStringAsFixed(1)}k';
    final isWhole = (val - val.roundToDouble()).abs() < 0.005;
    return '$sym${val.toStringAsFixed(isWhole ? 0 : 1)}';
  }
}
