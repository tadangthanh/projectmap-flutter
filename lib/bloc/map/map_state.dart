import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/place_type.dart';
import 'package:map/entity/travel_mode_enum.dart';

class MapState {}

class LoadingMapState extends MapState {}

class LoadedMapState extends MapState {
  final LocationData locationData;
  final Set<Marker> markers;
  final bool trafficEnabled;
  final MapType currentMapType;
  final bool isFollowCamera;
  final Place? place;
  final GoogleMapController? googleMapController;
  final DirectionInfo? directionInfo;
  final bool isLoading;
  final bool isJourneyStarted;
  final String query;
  final PlaceTypes? searchByNearSelectedType;
  final VehicleType? vehicleType;
  LoadedMapState(this.locationData,this.markers,

      this.currentMapType,this.trafficEnabled,this.isFollowCamera,{this.googleMapController,this.place,this.directionInfo,this.isLoading=false,this.isJourneyStarted=false,this.query='',this.searchByNearSelectedType,this.vehicleType});
}
class MapErrorState extends MapState {
  final String message;

  MapErrorState(this.message);
}
