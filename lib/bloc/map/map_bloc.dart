import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:map/bloc/map/map_event.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/service/place_search.dart';
import 'package:map/service/user_service.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final UserService _userService = getIt<UserService>();
  final PlaceSearch _placeSearch  = getIt<PlaceSearch>();
  late User _user;
  late GoogleMapController? _googleMapController;
  late LocationData _currentPosition;
  late Set<Marker> _markers;
  late Marker _placeSearchMarker=const Marker(markerId: MarkerId(''));
  late MapType _currentMapType = MapType.normal;
  final Location _location = Location();
  late bool _isFollowCamera = true;
  late double _angelView = 0;
  late double _zoom = 16.0;
  late bool _trafficEnabled = false;
  late BitmapDescriptor _customMarkerUser;

  MapBloc() : super(LoadingMapState()) {
    on<InitMapEvent>((event, emit) async {
      await _init(emit);
    });
    on<FoundLocationEvent>((event, emit) async {
      await _foundLocationSearch(emit, event.place);
    });
    on<LoadedMapControllerEvent>((event, emit) async {
      await _loadedMapControllerState(emit, event);
    });
    on<CurrentLocationEvent>((event, emit) async {
      await _getCurrentLocation(emit);
    });
    on<MapCameraMoveEvent>((event, emit) async {
      _isFollowCamera = false;
    });
    on<DirectionEvent>((event, emit) async {
       await _direction(emit,event.origin, event.destination);
    });
    on<ChangeMapDetailEvent>((event, emit) async {
      _trafficEnabled = event.trafficEnabled;
      emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
          _trafficEnabled, _isFollowCamera,
          googleMapController: _googleMapController));
    });
    on<ChangeMapTypeEvent>((event, emit) async {
      _currentMapType = event.mapType;
      emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
          _trafficEnabled, _isFollowCamera,
          googleMapController: _googleMapController));
    });
    add(InitMapEvent());
  }
  Future<void> _direction(Emitter<MapState> emit,LatLng origin, LatLng destination) async {
    // Tạo đường đi giữa 2 điểm
    // ignore: unused_local_variable
    DirectionInfo directionInfo =await _placeSearch.getPolylinePoints(origin,destination,);
    // Polyline polyline = Polyline(
    //   polylineId: const PolylineId('route'),
    //   points: route,
    //   color: Colors.blue,
    //   width: 5,
    // );
    emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
        _trafficEnabled, _isFollowCamera,
        googleMapController: _googleMapController,directionInfo: directionInfo));
  }


  Future<void> _foundLocationSearch(Emitter<MapState> emit,Place place) async {
    _markers.removeWhere((element) => element.markerId.value == _placeSearchMarker.markerId.value);
    _placeSearchMarker = Marker(
      markerId: MarkerId(place.placeId),
      position: LatLng(place.latitude, place.longitude),
      infoWindow: InfoWindow(title: place.name),
      icon: BitmapDescriptor.defaultMarker,
    );
    _markers.add(
        _placeSearchMarker
    );
   await _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
          LatLng(place.latitude, place.longitude),
          zoom: 14.0,
          tilt: 0,
        ),
      ),
    );


    emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
        _trafficEnabled, _isFollowCamera,
        googleMapController: _googleMapController,place: place));
  }

  Future<void> _loadedMapControllerState(
      Emitter<MapState> emit, LoadedMapControllerEvent event) async {
    _googleMapController = event.googleMapController;
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // Cập nhật vị trí khi có sự thay đổi
      _updateLocation(currentLocation);
    });
    emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
        _trafficEnabled, _isFollowCamera,
        googleMapController: _googleMapController));
  }

  Future<void> _init(Emitter<MapState> emit) async {
    emit(LoadingMapState());
    LocationData currentLocation = await _location.getLocation();
    // Kiểm tra và yêu cầu bật dịch vụ vị trí
    if (!await _isOpenLocationService(_location) ||
        !await _isAccessLocation(_location)) {
      emit(LoadingMapState());
      return;
    }
    User? user = await _userService.getUser();
    if (user == null) {
      emit(LoadingMapState());
      return;
    }
    Set<Marker> markers = await _initMarker(user, currentLocation);
    _markers = markers;
    _user = user;
    _currentPosition = currentLocation;
    _trafficEnabled = false;
    emit(LoadedMapState(currentLocation, markers, _currentMapType,
        _trafficEnabled, _isFollowCamera,
        googleMapController: null));
  }

  Future<Set<Marker>> _initMarker(user, LocationData currentLocation) async {
    const LatLng hoangSa = LatLng(16.1, 111.5); // Tọa độ gần Hoàng Sa
    const LatLng truongSa = LatLng(12.5, 114.5); // Tọa độ gần Trường Sa
    _customMarkerUser = await _convertAvatarUrlToBitMapDescriptor(user);
    return {
      Marker(
        markerId: const MarkerId('HoangSa'),
        position: hoangSa,
        infoWindow: const InfoWindow(title: 'Quần đảo Hoàng Sa (Vietnam)'),
        icon: await _customMarker("assets/icons/vietnam-location.png"),
      ),
      Marker(
        markerId: const MarkerId('TruongSa'),
        position: truongSa,
        infoWindow: const InfoWindow(title: 'Quần đảo Trường Sa (Vietnam)'),
        icon: await _customMarker("assets/icons/vietnam-location.png"),
      ),
      Marker(
        markerId: MarkerId(user.googleId),
        position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
        icon: _customMarkerUser,
      ),
    };
  }

  Future<bool> _isOpenLocationService(Location location) async {
    bool serviceEnabled = await location.serviceEnabled();
    // Kiểm tra và yêu cầu bật dịch vụ vị trí
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Yêu cầu bật dịch vụ vị trí
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return false;
      }
    }
    return true;
  }

  Future<bool> _isAccessLocation(Location location) async {
    // Kiểm tra quyền truy cập vị trí
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _getCurrentLocation(Emitter<MapState> emit) async {
    // neu _isFollowCamera = false thi zoom = 16.0, nguoc lai thi zoom = 19.0
    _zoom = _zoom == 16.0 ? 19.0 : 16.0;
    _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target:
              LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
          zoom: _zoom,
          tilt: _angelView == 0 ? 45 : 0,
        ),
      ),
    );
    // neu follow camera thi _angelView = 0, nguoc lai thi _angelView = 45
    _angelView == 0 ? _angelView = 45 : _angelView = 0;
    _isFollowCamera = true;
  }

  Future<void> _updateLocation(LocationData currentLocation) async {
    _currentPosition = currentLocation; // Cập nhật vị trí hiện tại
    // Xóa Marker cũ (nếu có)
    _markers.removeWhere((marker) => marker.markerId.value == _user.googleId);
    _markers.add(
      Marker(
        icon: _customMarkerUser,
        markerId: MarkerId(_user.googleId),
        position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
      ),
    );
    // Điều hướng camera tới vị trí mới
    if (_isFollowCamera) {
      _angelView == 0;
      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 16.0,
            tilt: _angelView,
          ),
        ),
      );
    }
  }

  Future<BitmapDescriptor> _convertAvatarUrlToBitMapDescriptor(user) async {
    // Tải ảnh từ URL
    final url = user.avatarUrl; // Thay thế bằng URL thực tế
    if (url == null || url.trim().isEmpty) {
      return BitmapDescriptor.asset(
          const ImageConfiguration(
            size: Size(35, 35),
          ),
          'assets/icons/user-location.png');
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return BitmapDescriptor.bytes(response.bodyBytes, width: 35, height: 35);
    } else {
      throw Exception('Failed to load marker image');
    }
  }

  Future<AssetMapBitmap> _customMarker(String urlAsset) {
    return BitmapDescriptor.asset(
        const ImageConfiguration(
          devicePixelRatio: 2.5,
          size: Size(48, 48),
        ),
        urlAsset);
  }
}
