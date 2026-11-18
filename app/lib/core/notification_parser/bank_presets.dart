class BankAppPreset {
  final String name;
  final String packageName;
  final String shortName;
  final String type; // 'bank', 'ewallet', 'cash'
  final String colorHex;
  final String iconName;
  final List<String> keywords;

  const BankAppPreset({
    required this.name,
    required this.packageName,
    String? shortName,
    this.type = 'bank',
    this.colorHex = '#10B981',
    this.iconName = 'landmark',
    this.keywords = const [],
  }) : shortName = shortName ?? name;

  @override
  String toString() => '$name ($packageName)';
}

const List<BankAppPreset> kPopularBankAppPresets = [
  BankAppPreset(name: 'BCA (BCA Mobile)', packageName: 'com.bca', shortName: 'BCA', colorHex: '#0060AF', keywords: ['bca', 'klikbca']),
  BankAppPreset(name: 'myBCA', packageName: 'com.bca.mybca', shortName: 'myBCA', colorHex: '#0060AF', keywords: ['mybca']),
  BankAppPreset(name: 'blu by BCA Digital', packageName: 'com.bcadigital.blu', shortName: 'blu', colorHex: '#00A3FF', keywords: ['blu', 'bcadigital']),
  BankAppPreset(name: 'Livin by Mandiri', packageName: 'com.bankmandiri.livin', shortName: 'Mandiri', colorHex: '#002D62', keywords: ['mandiri', 'livin']),
  BankAppPreset(name: 'Bank Jago', packageName: 'com.bankjago.app', shortName: 'Jago', colorHex: '#FF7300', keywords: ['jago', 'kantong jago']),
  BankAppPreset(name: 'SeaBank Indonesia', packageName: 'com.seabank.id', shortName: 'SeaBank', colorHex: '#FF5722', keywords: ['seabank', 'sea bank']),
  BankAppPreset(name: 'BRImo (BRI)', packageName: 'id.co.bri.brimo', shortName: 'BRI', colorHex: '#00529C', keywords: ['bri', 'brimo']),
  BankAppPreset(name: 'wondr by BNI', packageName: 'id.co.bni.wondr', shortName: 'BNI', colorHex: '#F15A24', keywords: ['bni', 'wondr']),
  BankAppPreset(name: 'Krom Bank', packageName: 'id.krom.bank', shortName: 'Krom', colorHex: '#00E5FF', keywords: ['krom']),
  BankAppPreset(name: 'BSI Mobile', packageName: 'com.bsi.mobile', shortName: 'BSI', colorHex: '#00A39D', keywords: ['bsi', 'syariah']),
  BankAppPreset(name: 'Bank Neo Commerce (Neobank)', packageName: 'com.bankneo.neobank', shortName: 'Neobank', colorHex: '#FFD700', keywords: ['neo', 'neobank', 'bnc']),
  BankAppPreset(name: 'Jenius (BTPN)', packageName: 'com.btpn.dc', shortName: 'Jenius', colorHex: '#0099DA', keywords: ['jenius', 'btpn']),
  BankAppPreset(name: 'Allo Bank', packageName: 'id.allobank.mobile', shortName: 'Allo', colorHex: '#7C3AED', keywords: ['allo', 'allobank']),
  BankAppPreset(name: 'Line Bank', packageName: 'com.linecorp.linebankid', shortName: 'Line Bank', colorHex: '#00C300', keywords: ['line bank', 'linebank']),
  BankAppPreset(name: 'Superbank', packageName: 'id.co.superbank.retail', shortName: 'Superbank', colorHex: '#2563EB', keywords: ['superbank']),
  BankAppPreset(name: 'OCTO Mobile (CIMB Niaga)', packageName: 'cimb.octomobile.android', shortName: 'CIMB Niaga', colorHex: '#ED1B2D', keywords: ['cimb', 'octo', 'niaga']),
  BankAppPreset(name: 'Permata ME', packageName: 'com.bankpermata.mobile', shortName: 'Permata', colorHex: '#78BE20', keywords: ['permata']),
  BankAppPreset(name: 'Danamon D-Bank PRO', packageName: 'com.danamon.dbank', shortName: 'Danamon', colorHex: '#FF7900', keywords: ['danamon', 'dbank']),
  BankAppPreset(name: 'Bank Saqu', packageName: 'id.banksaqu.app', shortName: 'Bank Saqu', colorHex: '#00B14F', keywords: ['saqu']),
  BankAppPreset(name: 'Flip', packageName: 'id.flip', shortName: 'Flip', type: 'ewallet', colorHex: '#FA591D', iconName: 'smartphone', keywords: ['flip']),
  BankAppPreset(name: 'OVO', packageName: 'ovo.id', shortName: 'OVO', type: 'ewallet', colorHex: '#4C3494', iconName: 'smartphone', keywords: ['ovo']),
  BankAppPreset(name: 'GoPay / Gojek', packageName: 'com.gojek.app', shortName: 'GoPay', type: 'ewallet', colorHex: '#00AED6', iconName: 'smartphone', keywords: ['gopay', 'gojek']),
  BankAppPreset(name: 'DANA', packageName: 'id.dana', shortName: 'DANA', type: 'ewallet', colorHex: '#118EEA', iconName: 'smartphone', keywords: ['dana']),
  BankAppPreset(name: 'ShopeePay', packageName: 'com.shopee.id', shortName: 'ShopeePay', type: 'ewallet', colorHex: '#EE4D2D', iconName: 'smartphone', keywords: ['shopee', 'shopeepay']),
  BankAppPreset(name: 'LinkAja', packageName: 'com.telkom.mwallet', shortName: 'LinkAja', type: 'ewallet', colorHex: '#ED1C24', iconName: 'smartphone', keywords: ['linkaja']),
];

const List<Set<String>> _kPackageAliasGroups = [
  {'id.co.bankbkemobile.digitalbank', 'com.seabank.id', 'com.sea.bank'},
  {'com.jago.digitalbanking', 'com.jago.digitalBanking', 'com.bankjago.app', 'id.co.bankjago'},
  {'com.bca', 'com.bca.mobile'},
  {'com.bca.mybca', 'com.bca.mybca.omni.android'},
  {'com.bcadigital.blu', 'id.co.bcadigital.blu'},
  {'com.bankmandiri.livin', 'id.bmri.livin', 'com.bankmandiri.mandirionline'},
  {'id.co.bri.brimo', 'com.bri.brimo'},
  {'id.co.bni.wondr', 'id.bni.wondr', 'src.com.bni'},
  {'com.bsi.mobile', 'id.co.bankbsi.bsimobile', 'co.id.bankbsi.superapp'},
  {'com.bankneo.neobank', 'com.bnc.finance', 'id.co.bankneo.neobank'},
  {'com.btpn.dc', 'id.co.btpn.jenius'},
  {'id.allobank.mobile', 'com.alloapp.yump', 'com.allobank.allobank'},
  {'com.linecorp.linebankid', 'id.co.linebank', 'com.kebhana.linebank'},
  {'id.co.superbank.retail', 'id.co.bankfama.superbank', 'com.superbank.app'},
  {'cimb.octomobile.android', 'id.co.cimbniaga.mobile.android'},
  {'com.bankpermata.mobile', 'net.myinfosys.PermataMobileX', 'net.myinfosys.permatamobilex', 'id.co.permatabank.permatame'},
  {'com.danamon.dbank', 'com.danamon.dbankpro', 'id.co.danamon.dbankpro'},
  {'id.krom.bank', 'com.krombank.id', 'id.co.krombank'},
  {'id.banksaqu.app', 'com.banksaqu.id'},
  {'id.flip'},
  {'ovo.id', 'id.ovo'},
  {'com.gojek.app', 'com.gojek.gopay'},
  {'id.dana', 'com.dana'},
  {'com.shopee.id', 'com.shopeepay.id'},
  {'com.telkom.mwallet', 'id.linkaja'},
];

Set<String> expandPackageAliases(String packageName) {
  final clean = packageName.trim();
  final low = clean.toLowerCase();
  if (low.isEmpty) return const {};
  final result = <String>{clean, low};
  for (final group in _kPackageAliasGroups) {
    if (group.any((p) => p.toLowerCase() == low)) {
      result.addAll(group);
    }
  }
  return result;
}

BankAppPreset? findBankPresetByPackage(String packageName) {
  final aliases = expandPackageAliases(packageName).map((e) => e.toLowerCase()).toSet();
  for (final p in kPopularBankAppPresets) {
    if (aliases.contains(p.packageName.toLowerCase())) {
      return p;
    }
  }
  return null;
}

BankAppPreset? findBankPresetByQuery(String query) {
  final clean = query.trim().toLowerCase();
  if (clean.isEmpty) return null;
  final byPackage = findBankPresetByPackage(clean);
  if (byPackage != null) return byPackage;

  for (final p in kPopularBankAppPresets) {
    if (p.shortName.toLowerCase() == clean || p.name.toLowerCase() == clean) return p;
    for (final kw in p.keywords) {
      if (kw.isNotEmpty && clean == kw.toLowerCase()) return p;
    }
  }
  for (final p in kPopularBankAppPresets) {
    for (final kw in p.keywords) {
      if (kw.isNotEmpty && clean.contains(kw.toLowerCase())) return p;
    }
  }
  for (final p in kPopularBankAppPresets) {
    final sLow = p.shortName.toLowerCase();
    final nLow = p.name.toLowerCase();
    if (clean.contains(sLow) || sLow.contains(clean) || clean.contains(nLow) || nLow.contains(clean)) {
      return p;
    }
  }
  return null;
}
