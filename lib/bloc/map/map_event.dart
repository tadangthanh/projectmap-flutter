import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/entity/place.dart';

class MapEvent {}
class InitMapEvent extends MapEvent{}
class LoadedMapControllerEvent extends MapEvent{
  final GoogleMapController googleMapController;

  LoadedMapControllerEvent(this.googleMapController);
}
class CurrentLocationEvent extends MapEvent{
}
class MapCameraMoveEvent extends MapEvent{}
class ChangeMapTypeEvent extends MapEvent{
  final MapType mapType;
  ChangeMapTypeEvent(this.mapType);
}
class  ChangeMapViewEvent extends MapEvent{
  final LatLng latLng;
  ChangeMapViewEvent(this.latLng);
}
class ChangeMapDetailEvent extends MapEvent{
  final bool trafficEnabled;
  ChangeMapDetailEvent(this.trafficEnabled);
}
class FoundLocationEvent extends MapEvent{
  final Place place;
  FoundLocationEvent(this.place);
}

class DirectionEvent extends MapEvent{
  final LatLng origin;
  final LatLng destination;
  DirectionEvent(this.origin,this.destination);
}