import 'package:flutter/material.dart';

class CategoryIconItem {
  final String id;
  final IconData icon;
  final String label;

  const CategoryIconItem({
    required this.id,
    required this.icon,
    required this.label,
  });
}

class CategoryIconResolver {
  static const List<CategoryIconItem> availableIcons = [
    CategoryIconItem(id: 'utensils', icon: Icons.restaurant_rounded, label: 'Makanan'),
    CategoryIconItem(id: 'coffee', icon: Icons.coffee_rounded, label: 'Kopi & Kafe'),
    CategoryIconItem(id: 'shopping_bag', icon: Icons.shopping_bag_rounded, label: 'Belanja'),
    CategoryIconItem(id: 'storefront', icon: Icons.storefront_rounded, label: 'Toko & Pasar'),
    CategoryIconItem(id: 'car', icon: Icons.directions_car_rounded, label: 'Transportasi'),
    CategoryIconItem(id: 'local_gas_station', icon: Icons.local_gas_station_rounded, label: 'Bahan Bakar'),
    CategoryIconItem(id: 'receipt', icon: Icons.receipt_long_rounded, label: 'Tagihan'),
    CategoryIconItem(id: 'electric_bolt', icon: Icons.electric_bolt_rounded, label: 'Listrik'),
    CategoryIconItem(id: 'wifi', icon: Icons.wifi_rounded, label: 'Internet & Pulsa'),
    CategoryIconItem(id: 'film', icon: Icons.play_circle_fill_rounded, label: 'Hiburan'),
    CategoryIconItem(id: 'music', icon: Icons.music_note_rounded, label: 'Musik'),
    CategoryIconItem(id: 'heart_pulse', icon: Icons.favorite_rounded, label: 'Kesehatan'),
    CategoryIconItem(id: 'fitness_center', icon: Icons.fitness_center_rounded, label: 'Olahraga'),
    CategoryIconItem(id: 'graduation_cap', icon: Icons.school_rounded, label: 'Pendidikan'),
    CategoryIconItem(id: 'home', icon: Icons.home_rounded, label: 'Rumah & Kost'),
    CategoryIconItem(id: 'credit_card', icon: Icons.credit_card_rounded, label: 'Cicilan'),
    CategoryIconItem(id: 'flight', icon: Icons.flight_rounded, label: 'Travel'),
    CategoryIconItem(id: 'pets', icon: Icons.pets_rounded, label: 'Hewan'),
    CategoryIconItem(id: 'volunteer_activism', icon: Icons.volunteer_activism_rounded, label: 'Donasi'),
    CategoryIconItem(id: 'work', icon: Icons.work_rounded, label: 'Pekerjaan'),
    CategoryIconItem(id: 'banknote', icon: Icons.account_balance_wallet_rounded, label: 'Gaji & Kas'),
    CategoryIconItem(id: 'sparkles', icon: Icons.auto_awesome_rounded, label: 'Bonus'),
    CategoryIconItem(id: 'trending_up', icon: Icons.trending_up_rounded, label: 'Investasi'),
    CategoryIconItem(id: 'category', icon: Icons.category_rounded, label: 'Lainnya'),
  ];

  static IconData mapCategoryIcon(String? name, {IconData fallback = Icons.receipt_long_rounded}) {
    switch (name?.toLowerCase()) {
      case 'utensils': case 'restaurant': case 'fastfood': return Icons.restaurant_rounded;
      case 'coffee': case 'cafe': case 'local_cafe': return Icons.coffee_rounded;
      case 'shopping_bag': case 'shopping_cart': return Icons.shopping_bag_rounded;
      case 'storefront': case 'store': return Icons.storefront_rounded;
      case 'car': case 'directions_car': return Icons.directions_car_rounded;
      case 'local_gas_station': case 'gas': case 'gas_station': return Icons.local_gas_station_rounded;
      case 'receipt': case 'receipt_long': return Icons.receipt_long_rounded;
      case 'electric_bolt': case 'bolt': case 'flash_on': return Icons.electric_bolt_rounded;
      case 'wifi': case 'internet': return Icons.wifi_rounded;
      case 'film': case 'movie': case 'play': return Icons.play_circle_fill_rounded;
      case 'music': case 'music_note': return Icons.music_note_rounded;
      case 'heart_pulse': case 'favorite': return Icons.favorite_rounded;
      case 'fitness_center': case 'gym': case 'sports': return Icons.fitness_center_rounded;
      case 'graduation_cap': case 'school': return Icons.school_rounded;
      case 'home': case 'house': return Icons.home_rounded;
      case 'credit_card': case 'card': return Icons.credit_card_rounded;
      case 'flight': case 'travel': return Icons.flight_rounded;
      case 'pets': case 'pet': return Icons.pets_rounded;
      case 'volunteer_activism': case 'donation': case 'handshake': return Icons.volunteer_activism_rounded;
      case 'work': case 'business': return Icons.work_rounded;
      case 'banknote': case 'account_balance_wallet': case 'wallet': return Icons.account_balance_wallet_rounded;
      case 'sparkles': case 'auto_awesome': return Icons.auto_awesome_rounded;
      case 'trending_up': return Icons.trending_up_rounded;
      case 'repeat': case 'swap_horiz': return Icons.swap_horiz_rounded;
      case 'savings': return Icons.savings_rounded;
      case 'flag': return Icons.flag_rounded;
      case 'category': return Icons.category_rounded;
      default: return fallback;
    }
  }
}
