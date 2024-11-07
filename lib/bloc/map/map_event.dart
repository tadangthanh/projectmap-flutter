import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/map_theme.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/travel_mode_enum.dart';
import 'package:map/entity/user.dart';

import '../../dto/group_location_request.dart';
import '../../entity/place_type.dart';

class MapEvent {}

class InitMapEvent extends MapEvent {}

// sự kiện load controller của google map
class MapControllerLoadedEvent extends MapEvent {
  final GoogleMapController googleMapController;

  MapControllerLoadedEvent(this.googleMapController);
}

class CurrentLocationEvent extends MapEvent {}

class MapCameraMoveEvent extends MapEvent {}

class ChangeMapTypeEvent extends MapEvent {
  final MapType mapType;

  ChangeMapTypeEvent(this.mapType);
}

class ChangeMapDetailEvent extends MapEvent {
  final bool trafficEnabled;
  ChangeMapDetailEvent(this.trafficEnabled);
}

class FoundLocationEvent extends MapEvent {
  final Place place;
  FoundLocationEvent(this.place);
}

class DirectionEvent extends MapEvent {
  final LatLng destination;
  final LatLng origin;
  final Place place;
  DirectionEvent(this.origin, this.destination, this.place);
}

class StartTrackingDirectionEvent extends MapEvent {
  final DirectionInfo directionInfo;
  StartTrackingDirectionEvent(this.directionInfo);
}

class StopTrackingDirectionEvent extends MapEvent {}

class LocationChangedEvent extends MapEvent {
  final LocationData currentLocation;
  LocationChangedEvent(this.currentLocation);
}

class CompleteDirectionEvent extends MapEvent {}

class FindNearByTypeEvent extends MapEvent {
  final PlaceTypes type;
  final LocationData locationData;

  FindNearByTypeEvent(this.type, this.locationData);
}

class MarkerTappedEvent extends MapEvent {
  final Place place;

  MarkerTappedEvent(this.place);
}

class ChangeTransportModeEvent extends MapEvent {
  final VehicleType vehicleType;

  ChangeTransportModeEvent(this.vehicleType);
}
// sự kiện chọn vị trí trên bản đồ
class SelectLocationEvent extends MapEvent {
  final bool isEnabledSelectLocation;
  SelectLocationEvent(this.isEnabledSelectLocation);
}
// sự kiện chọn vị trí trên bản đồ
class SelectedLocationEvent extends MapEvent {
  final LatLng location;
  SelectedLocationEvent(this.location);
}

class UpdateMarkersEvent extends MapEvent {}

class MarkerFriendTappedEvent extends MapEvent {
  final User friend;
  MarkerFriendTappedEvent(this.friend);
}

class CloseFriendTappedEvent extends MapEvent {}

class ChangeMapThemeEvent extends MapEvent {
  final MapTheme mapTheme;

  ChangeMapThemeEvent(this.mapTheme);
}

class TappedPolylineEvent extends MapEvent {
  String polylineId;
  String distance;
  String duration;
  TappedPolylineEvent(this.polylineId, this.distance, this.duration);
}
class LatLngTappedEvent extends MapEvent {
  final LatLng location;
  LatLngTappedEvent(this.location);
}
class AddLocationToGroupEvent extends MapEvent {
  final GroupLocationRequest groupLocationRequest;
  AddLocationToGroupEvent(this.groupLocationRequest);
}
class ClearMessageEvent extends MapEvent {}