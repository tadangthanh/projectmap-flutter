import 'package:map/entity/polyline.dart';

class RouteResponse{
  final int distanceMeters;
  final String duration;
  final PolylineResponse polyline;

  RouteResponse(this.distanceMeters, this.duration, this.polyline);

  factory RouteResponse.fromJson(Map<String, dynamic> json){
    return RouteResponse(
      json['distanceMeters']??0,
      json['duration']??'0s',
      PolylineResponse.fromJson(json['polyline'])
    );
  }
}