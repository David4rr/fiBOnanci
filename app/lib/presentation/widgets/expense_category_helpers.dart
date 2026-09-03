import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

Color getExpenseCategoryColor(String? category, String? title, String? type, int index) {
  final str = '${category ?? ''} ${title ?? ''}'.toLowerCase();
  if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('taco') || str.contains('mcd') || str.contains('kfc') || str.contains('kopi') || str.contains('cafe')) {
    return const Color(0xFFCBB776);
  }
  if (str.contains('spotify') || str.contains('musik') || str.contains('music') || str.contains('hiburan') || str.contains('entertain') || str.contains('game')) {
    return const Color(0xFF7E9D75);
  }
  if (str.contains('amazon') || str.contains('belanja') || str.contains('product') || str.contains('shop') || str.contains('shopee') || str.contains('tokopedia')) {
    return const Color(0xFFFF7052);
  }
  if (str.contains('transport') || str.contains('grab') || str.contains('gojek') || str.contains('uber') || str.contains('bensin') || str.contains('parkir')) {
    return const Color(0xFF2EBFA5);
  }
  if (str.contains('tagihan') || str.contains('bill') || str.contains('listrik') || str.contains('internet') || str.contains('pulsa') || str.contains('pln')) {
    return const Color(0xFFA78BFA);
  }
  if (type == 'income') {
    return AppColors.neoMint;
  }

  const fallbackPalette = [
    Color(0xFFFF7052),
    Color(0xFF7E9D75),
    Color(0xFFCBB776),
    Color(0xFF2EBFA5),
    Color(0xFFA78BFA),
    Color(0xFFD4F442),
  ];
  return fallbackPalette[index % fallbackPalette.length];
}

IconData getExpenseCategoryIcon(String? category, String? title) {
  final str = '${category ?? ''} ${title ?? ''}'.toLowerCase();
  if (str.contains('makan') || str.contains('food') || str.contains('resto') || str.contains('taco') || str.contains('mcd') || str.contains('kfc') || str.contains('kopi') || str.contains('cafe')) {
    return Icons.restaurant_rounded;
  }
  if (str.contains('spotify') || str.contains('musik') || str.contains('music')) {
    return Icons.music_note_rounded;
  }
  if (str.contains('netflix') || str.contains('film') || str.contains('movie') || str.contains('hiburan') || str.contains('game')) {
    return Icons.play_arrow_rounded;
  }
  if (str.contains('amazon') || str.contains('belanja') || str.contains('shop') || str.contains('shopee') || str.contains('tokopedia') || str.contains('product')) {
    return Icons.shopping_bag_rounded;
  }
  if (str.contains('transport') || str.contains('grab') || str.contains('gojek') || str.contains('uber') || str.contains('bensin')) {
    return Icons.directions_car_rounded;
  }
  if (str.contains('transfer')) {
    return Icons.swap_horiz_rounded;
  }
  return Icons.receipt_long_rounded;
}
