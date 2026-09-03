/// Hard-drop regex blacklist for security tokens, marketing promotions, and ad pricing.
class NotificationBlacklist {
  // Security tokens, OTP, passwords, promos, marketing
  static final RegExp securityAndMarketing = RegExp(
    r'\b('
    // Security & Auth Tokens
    r'otp|kode\s+otp|kode\s+verifikasi|verification\s+code|passcode|rahasia|password|kata\s+sandi|token|pin|cvv|cvc|'
    r'jangan\s+berikan|jangan\s+kasih|do\s+not\s+share|jaga\s+kerahasiaan|waspada\s+penipuan|ubah\s+pin|ganti\s+pin|reset\s+password|'
    // Marketing, Promos, Discounts & Rewards
    r'promo|promosi|promotion|diskon|discount|cashback|voucher|kupon|coupon|'
    r'hadiah|reward|rewards|menangkan|klaim|claim|bonus|'
    r'special\s+offer|penawaran|exclusive\s+deal|hot\s+deal|best\s+deal|'
    r'flash\s+sale|mega\s+sale|cuci\s+gudang|big\s+sale|super\s+sale|gajian\s+sale|payday\s+sale|'
    r'gebyar|undian|giveaway|lucky\s+draw|spin\s*&\s*win|games\s+berhadiah|'
    // Referral & Invite
    r'ajak\s+teman|undang\s+teman|referral|referal|kode\s+referral|invite\s+friend|invite\s+friends|'
    // Loans, Credit, PayLater advertising & investment promos
    r'ajukan\s+pinjaman|pinjaman\s+online|pinjol|dana\s+cepat|butuh\s+dana|plafon\s+s\.d|plafon\s+hingga|limit\s+hingga|limit\s+s\.d|'
    r'limit\s+paylater|limit\s+spaylater|limit\s+gopaylater|aktifkan\s+spaylater|aktifkan\s+paylater|aktifkan\s+gopaylater|limit\s+kredit|limit\s+belanja|limit\s+pinjaman|dana\s+cicil|cicilan\s+0%|cicilan\s+ringan|'
    r'bunga\s+mulai|bunga\s+rendah|bunga\s+ringan|bunga\s+spesial|bunga\s+hingga|bunga\s+deposito|buka\s+deposito|buka\s+tabungan|investasi\s+mulai|'
    // Call-to-action & Advertising Pricing
    r'mulai\s+dari|starting\s+from|start\s+from|serba\s+rp|cuma\s+rp|hanya\s+rp|cukup\s+bayar|mulai\s+rp|mulai\s+harga|'
    r'hemat\s+hingga|hemat\s+s\.d|hemat\s+s/d|diskon\s+hingga|cashback\s+hingga|cashback\s+s\.d|'
    r'gratis\s+ongkir|free\s+ongkir|bebas\s+ongkir|free\s+shipping|'
    r'yuk\s+jajan|pesan\s+sekarang|order\s+sekarang|beli\s+sekarang|belanja\s+sekarang|checkout\s+sekarang|check\s+out\s+sekarang|'
    r'buruan|jangan\s+lewatkan|don.t\s+miss|spesial\s+untukmu|khusus\s+untukmu|rekomendasi\s+untukmu|'
    r'iklan|advertisement|sponsored|sponsor'
    r')\b',
    caseSensitive: false,
  );

  static final RegExp adPricingAndCondition = RegExp(
    r'(?:'
    r'\b(?:hingga|s\.d|s\/d|up\s+to|maksimal|max\.?|plafon|limit)\s+(?:sebesar\s+)?(?:rp\.?|idr)?\s*[0-9]'
    r'|\b(?:min\.|min|minimal|minimum)\s+(?:belanja|transaksi|pembelian|order|orderan)?\s*(?:rp\.?|idr)?\s*[0-9]'
    r'|\b(?:mulai\s+dari|mulai|starting\s+from|start\s+from|serba|cuma|hanya|cukup\s+bayar)\s+(?:rp\.?|idr)\b'
    r')',
    caseSensitive: false,
  );

  static bool isBlacklisted(String text) {
    return securityAndMarketing.hasMatch(text) || adPricingAndCondition.hasMatch(text);
  }
}
