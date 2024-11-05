import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionInfo {
  late List<Polyline> polyline;
  late String distance;
  late String duration;

  DirectionInfo({required this.polyline, required this.distance, required this.duration});
}