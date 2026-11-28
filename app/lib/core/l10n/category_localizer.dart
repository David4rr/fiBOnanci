import 'package:flutter/widgets.dart';
import '../../data/database/app_database.dart';
import '../../l10n/app_localizations.dart';
import 'locale_notifier.dart';

/// Translates seeded default category names to the active UI locale while
/// preserving user-created custom category names verbatim.
class CategoryLocalizer {
  static String name(BuildContext context, {String? id, required String rawName}) {
    return byL10n(AppL10n.of(context), id: id, rawName: rawName);
  }

  static String entry(BuildContext context, CategoryEntry category) {
    return name(context, id: category.id, rawName: category.name);
  }

  static String byL10n(AppLocalizations l10n, {String? id, required String rawName}) {
    switch (id) {
      case 'cat_food':
        return l10n.catDefaultFood;
      case 'cat_transport':
        return l10n.catDefaultTransport;
      case 'cat_shopping':
        return l10n.catDefaultShopping;
      case 'cat_bills':
        return l10n.catDefaultBills;
      case 'cat_entertainment':
        return l10n.catDefaultEntertainment;
      case 'cat_health':
        return l10n.catDefaultHealth;
      case 'cat_education':
        return l10n.catDefaultEducation;
    }
    switch (rawName.trim()) {
      case 'Makanan & Minuman':
        return l10n.catDefaultFood;
      case 'Transportasi':
        return l10n.catDefaultTransport;
      case 'Belanja & Kebutuhan':
        return l10n.catDefaultShopping;
      case 'Tagihan & Utilitas':
        return l10n.catDefaultBills;
      case 'Hiburan & Langganan':
        return l10n.catDefaultEntertainment;
      case 'Kesehatan':
        return l10n.catDefaultHealth;
      case 'Pendidikan & Kursus':
        return l10n.catDefaultEducation;
      default:
        return rawName;
    }
  }
}
