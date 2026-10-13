class BankAppPreset {
  final String name;
  final String packageName;

  const BankAppPreset({required this.name, required this.packageName});

  @override
  String toString() => '$name ($packageName)';
}

const List<BankAppPreset> kPopularBankAppPresets = [
  BankAppPreset(name: 'Krom Bank', packageName: 'id.krom.bank'),
  BankAppPreset(name: 'BCA (BCA Mobile)', packageName: 'com.bca'),
  BankAppPreset(name: 'myBCA', packageName: 'com.bca.mybca'),
  BankAppPreset(name: 'blu by BCA Digital', packageName: 'com.bcadigital.blu'),
  BankAppPreset(name: 'Livin by Mandiri', packageName: 'com.bankmandiri.livin'),
  BankAppPreset(name: 'Bank Jago', packageName: 'com.bankjago.app'),
  BankAppPreset(name: 'SeaBank Indonesia', packageName: 'com.seabank.id'),
  BankAppPreset(name: 'BRImo (BRI)', packageName: 'id.co.bri.brimo'),
  BankAppPreset(name: 'wondr by BNI', packageName: 'id.co.bni.wondr'),
  BankAppPreset(name: 'BSI Mobile', packageName: 'com.bsi.mobile'),
  BankAppPreset(name: 'Bank Neo Commerce (Neobank)', packageName: 'com.bankneo.neobank'),
  BankAppPreset(name: 'Jenius (BTPN)', packageName: 'com.btpn.dc'),
  BankAppPreset(name: 'Allo Bank', packageName: 'id.allobank.mobile'),
  BankAppPreset(name: 'Line Bank', packageName: 'com.linecorp.linebankid'),
  BankAppPreset(name: 'Superbank', packageName: 'id.co.superbank.retail'),
  BankAppPreset(name: 'OCTO Mobile (CIMB Niaga)', packageName: 'cimb.octomobile.android'),
  BankAppPreset(name: 'Permata ME', packageName: 'com.bankpermata.mobile'),
  BankAppPreset(name: 'Danamon D-Bank PRO', packageName: 'com.danamon.dbank'),
  BankAppPreset(name: 'Bank Saqu', packageName: 'id.banksaqu.app'),
  BankAppPreset(name: 'Flip', packageName: 'id.flip'),
  BankAppPreset(name: 'OVO', packageName: 'ovo.id'),
  BankAppPreset(name: 'GoPay / Gojek', packageName: 'com.gojek.app'),
  BankAppPreset(name: 'DANA', packageName: 'id.dana'),
  BankAppPreset(name: 'ShopeePay', packageName: 'com.shopee.id'),
  BankAppPreset(name: 'LinkAja', packageName: 'com.telkom.mwallet'),
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
/// Returns all known Android package name aliases for the given [packageName].
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
