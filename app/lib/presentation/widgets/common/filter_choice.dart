/// Filter choice item for expandable search filter dropdowns.
class FilterChoice {
  final String value;
  final String label;
  final String? chipLabel;

  const FilterChoice({
    required this.value,
    required this.label,
    this.chipLabel,
  });
}

/// Default transaction type filter options (Dashboard, Expense History, Wallet Detail).
const kDefaultTransactionTypeChoices = [
  FilterChoice(value: 'all', label: 'Semua'),
  FilterChoice(value: 'expense', label: 'Pengeluaran', chipLabel: 'Tipe: EXPENSE'),
  FilterChoice(value: 'income', label: 'Pemasukan', chipLabel: 'Tipe: PEMASUKAN'),
  FilterChoice(value: 'transfer', label: 'Transfer', chipLabel: 'Tipe: TRANSFER'),
];

/// Default subscription / recurring bill status filter options (Tagihan & Langganan).
const kDefaultSubscriptionStatusChoices = [
  FilterChoice(value: 'all', label: 'Semua Status'),
  FilterChoice(value: 'unpaid', label: 'Belum Bayar', chipLabel: 'Status: Belum Bayar'),
  FilterChoice(value: 'paid', label: 'Sudah Lunas', chipLabel: 'Status: Sudah Lunas'),
];
