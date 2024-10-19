import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapState {}

class LoadingMapState extends MapState {}

class LoadedMapState extends MapState {
  final LocationData locationData;
  final Set<Marker> markers;
  final MapType currentMapType;
  final GoogleMapController? googleMapController;

  LoadedMapState(this.locationData,this.markers,
      this.currentMapType,{this.googleMapController});
}
