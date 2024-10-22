import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionInfo {
  late Set<Polyline> polyline;
  late List<String>? distance;
  late List<String>? duration;

  DirectionInfo({required this.polyline, required this.distance, required this.duration});
}