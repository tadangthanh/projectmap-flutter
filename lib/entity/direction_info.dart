import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionInfo {
  final Polyline polyline;
 final List<String>? distance;
 final List<String>? duration;

  DirectionInfo({required this.polyline, required this.distance, required this.duration});
}