import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class SymbolIcon extends StatelessWidget {
  const SymbolIcon({required this.name, super.key, this.size = 24});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconFor(name),
      color: DreamColors.textPrimary,
      size: size,
    );
  }
}

IconData _iconFor(String name) {
  switch (name.toLowerCase()) {
    case 'water':
    case 'ocean':
    case 'whale':
      return Icons.water_drop_outlined;
    case 'moon':
    case 'full moon':
      return Icons.dark_mode_outlined;
    case 'clock':
      return Icons.schedule_outlined;
    case 'door':
      return Icons.meeting_room_outlined;
    case 'city':
      return Icons.location_city_outlined;
    case 'dog':
      return Icons.pets_outlined;
    case 'sunflower':
      return Icons.wb_sunny_outlined;
    case 'glass':
      return Icons.diamond_outlined;
    case 'clouds':
      return Icons.cloud_outlined;
    default:
      return Icons.vpn_key_outlined;
  }
}
