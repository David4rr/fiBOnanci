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
  BankAppPreset(name: 'OVO', packageName: 'ovo.id'),
  BankAppPreset(name: 'GoPay / Gojek', packageName: 'com.gojek.app'),
  BankAppPreset(name: 'DANA', packageName: 'id.dana'),
  BankAppPreset(name: 'ShopeePay', packageName: 'com.shopee.id'),
  BankAppPreset(name: 'LinkAja', packageName: 'com.telkom.mwallet'),
];

BankAppPreset? findBankPresetByPackage(String packageName) {
  final lowPkg = packageName.toLowerCase().trim();
  for (final p in kPopularBankAppPresets) {
    if (p.packageName.toLowerCase() == lowPkg) {
      return p;
    }
  }
  return null;
}
