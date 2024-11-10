import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/dto/group_location_response.dart';
import 'package:map/dto/group_response_dto.dart';
import 'package:map/dto/location_dto.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/place_type.dart';
import 'package:map/entity/travel_mode_enum.dart';
import 'package:map/entity/user.dart';

class MapState {}

class LoadingMapState extends MapState {}

class LoadedMapState extends MapState {
  final LocationData locationData;
  final List<Marker> markers;
  final bool trafficEnabled;
  final MapType currentMapType;
  final bool isFollowCamera;
  final Place? place;
  final GoogleMapController? googleMapController;
  final DirectionInfo? directionInfo;
  final bool isLoading;
  final bool isOnJourneyStarted;
  final String query;
  final PlaceTypes? searchByNearSelectedType;
  final VehicleType? vehicleType;
  final bool isEnabledSelectLocation;
  final User? friendTapped;
  final String style;
  final String? message;
  final bool isEnableDeleteMarkerGroup;
  final LocationDto? locationMarkerGroupTapped;
  final List<GroupResponseDto> groups;
  final User? user;
  final List<User> friends;
  LoadedMapState(this.locationData,this.markers,this.currentMapType,this.trafficEnabled,this.isFollowCamera,
      {this.googleMapController,this.place,this.directionInfo,this.isLoading=false,this.isOnJourneyStarted=false,this.query='',
        this.searchByNearSelectedType,this.vehicleType,this.isEnabledSelectLocation=false,this.friendTapped,this.style='',this.message,this.isEnableDeleteMarkerGroup=false,this.locationMarkerGroupTapped,this.groups=const [],this.user,this.friends=const []});
}
class MapErrorState extends MapState {
  final String message;

  MapErrorState(this.message);
}
