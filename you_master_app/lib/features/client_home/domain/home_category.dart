import 'package:flutter/material.dart';

enum HomeCategory {
  all(label: 'Все', icon: Icons.grid_view_rounded),
  manicure(
    label: 'Маникюр',
    imageAsset: 'assets/images/filter_widget/manicure.png',
  ),
  brows(label: 'Брови', imageAsset: 'assets/images/filter_widget/eyebrows.png'),
  lashes(
    label: 'Ресницы',
    imageAsset: 'assets/images/filter_widget/lashes.png',
  ),
  makeup(label: 'Макияж', imageAsset: 'assets/images/filter_widget/makeup.png'),
  more(label: 'Ещё', icon: Icons.more_horiz_rounded);

  const HomeCategory({required this.label, this.icon, this.imageAsset});

  final String label;
  final IconData? icon;
  final String? imageAsset;
}
