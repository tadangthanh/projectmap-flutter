import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionInfo {
  late Set<Polyline> polyline;
  late Map<Color,String> distance;
  late Map<Color,String> duration;

  DirectionInfo({required this.polyline, required this.distance, required this.duration});
}