import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';
import '../../data/models/dream_symbol_catalog.dart';

class SymbolIcon extends StatelessWidget {
  const SymbolIcon({required this.name, super.key, this.size = 24});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      _iconFor(dreamSymbolIcon(name)),
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
    case 'river':
      return Icons.waves_outlined;
    case 'storm':
    case 'rain/storm':
      return Icons.thunderstorm_outlined;
    case 'fire':
      return Icons.local_fire_department_outlined;
    case 'moon':
    case 'full moon':
      return Icons.dark_mode_outlined;
    case 'sun':
    case 'sun/light':
      return Icons.light_mode_outlined;
    case 'clouds':
    case 'sky/clouds':
      return Icons.cloud_outlined;
    case 'house':
      return Icons.home_outlined;
    case 'room':
      return Icons.bedroom_parent_outlined;
    case 'clock':
    case 'clock/time':
      return Icons.schedule_outlined;
    case 'door':
      return Icons.meeting_room_outlined;
    case 'window':
      return Icons.window_outlined;
    case 'key':
    case 'key/lock':
      return Icons.vpn_key_outlined;
    case 'path':
    case 'road/path':
      return Icons.route_outlined;
    case 'bridge':
      return Icons.commit_outlined;
    case 'stairs':
      return Icons.stairs_outlined;
    case 'city':
      return Icons.location_city_outlined;
    case 'flower':
    case 'garden/flowers':
    case 'sunflower':
      return Icons.local_florist_outlined;
    case 'tree':
    case 'tree/forest':
      return Icons.forest_outlined;
    case 'mountain':
      return Icons.terrain_outlined;
    case 'train':
    case 'train/station':
      return Icons.train_outlined;
    case 'vehicle':
      return Icons.directions_car_outlined;
    case 'school':
    case 'school/test':
      return Icons.school_outlined;
    case 'work':
    case 'work/office':
      return Icons.work_outline;
    case 'message':
    case 'phone/message':
      return Icons.forum_outlined;
    case 'glass':
    case 'mirror/glass':
      return Icons.diamond_outlined;
    case 'person':
    case 'stranger':
      return Icons.person_outline;
    case 'family':
      return Icons.diversity_3_outlined;
    case 'child':
    case 'child/baby':
      return Icons.child_care_outlined;
    case 'animal':
      return Icons.cruelty_free_outlined;
    case 'dog':
      return Icons.pets_outlined;
    case 'cat':
      return Icons.pets_outlined;
    case 'bird':
      return Icons.flutter_dash_outlined;
    case 'snake':
      return Icons.gesture_outlined;
    case 'running':
    case 'chase/running':
      return Icons.directions_run_outlined;
    case 'flying':
      return Icons.flight_takeoff_outlined;
    case 'falling':
      return Icons.south_outlined;
    case 'search':
    case 'lost/search':
      return Icons.travel_explore_outlined;
    case 'money':
      return Icons.payments_outlined;
    case 'clothes':
      return Icons.checkroom_outlined;
    case 'food':
      return Icons.restaurant_outlined;
    case 'death':
      return Icons.change_circle_outlined;
    case 'party':
    case 'party/celebration':
      return Icons.celebration_outlined;
    case 'self':
    case 'self/identity':
      return Icons.badge_outlined;
    case 'memory':
      return Icons.history_outlined;
    case 'sparkle':
    case 'unknown':
      return Icons.auto_awesome_outlined;
    default:
      return Icons.auto_awesome_outlined;
  }
}
