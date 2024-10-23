import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';

import '../../entity/place_type.dart';

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
  final LatLng destination;
  final LatLng origin;
  final Place place;
  DirectionEvent(this.origin,this.destination,this.place);
}
class StartTrackingDirectionEvent extends MapEvent{
  final DirectionInfo directionInfo;
  StartTrackingDirectionEvent(this.directionInfo);
}
class LocationChangedEvent extends MapEvent {
  final LocationData currentLocation;
  LocationChangedEvent(this.currentLocation);
}
class CompleteDirectionEvent extends MapEvent{}
class FindNearByTypeEvent extends MapEvent{
  final PlaceTypes type;
  final LocationData locationData;
  FindNearByTypeEvent(this.type,this.locationData);
}
class MarkerTappedEvent extends MapEvent {
  final Place place;

  MarkerTappedEvent(this.place);
}