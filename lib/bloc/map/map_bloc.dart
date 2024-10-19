import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:map/bloc/map/map_event.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/service/user_service.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final UserService _userService = getIt<UserService>();
  late User _user;
  late GoogleMapController? _googleMapController;
  late LocationData _currentPosition;
  late Set<Marker> _markers;
  late MapType _currentMapType = MapType.normal;
  final Location _location = Location();
  late BitmapDescriptor _customIcon = BitmapDescriptor.defaultMarker;
  late bool _isFollowCamera = true;
  late double _angelView = 0;
  late double _zoom = 16.0;

  MapBloc() : super(LoadingMapState()) {
    on<InitMapEvent>((event, emit) async {
      await _init(emit);
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
    on<ChangeMapTypeEvent>((event, emit) async {
      _currentMapType = event.mapType;
      emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
          googleMapController: _googleMapController));
    });
    add(InitMapEvent());
  }

  Future<void> _loadedMapControllerState(
      Emitter<MapState> emit, LoadedMapControllerEvent event) async {
    _googleMapController = event.googleMapController;
    emit(LoadedMapState(_currentPosition, _markers, MapType.normal,
        googleMapController: event.googleMapController));
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
    _customMarker(user.avatarUrl);
    Set<Marker> markers = {
      Marker(
        markerId: MarkerId(user.googleId),
        position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
        infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
        icon: _customIcon,
      ),
    };
    _user = user;
    _currentPosition = currentLocation;
    _markers = markers;
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // Cập nhật vị trí khi có sự thay đổi
      _updateLocation(currentLocation);
    });
    emit(LoadedMapState(currentLocation, markers, _currentMapType,
        googleMapController: null));
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
    // Điều hướng camera tới vị trí hiện tại

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
    _angelView == 0 ? _angelView = 45 : _angelView = 0;
    _isFollowCamera = true;
    emit(LoadedMapState(_currentPosition, _markers, _currentMapType,
        googleMapController: _googleMapController));
  }

  Future<void> _updateLocation(LocationData currentLocation) async {
    _currentPosition = currentLocation; // Cập nhật vị trí hiện tại

    _markers.add(
      Marker(
        icon: _customIcon,
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

  void _customMarker(String avatarUrl) {
    BitmapDescriptor.asset(
            const ImageConfiguration(
              devicePixelRatio: 2.5,
              size: Size(48, 48),
            ),
            avatarUrl)
        .then((value) {
      _customIcon = value;
    });
  }

// Hàm chuyển đổi kiểu bản đồ
  void _changeMapType() {
    // Chuyển đổi giữa bản đồ vệ tinh (hybrid) và bản đồ thường
    _currentMapType == MapType.normal
        ? _currentMapType = MapType.hybrid // Sử dụng hybrid để giữ nhãn
        : _currentMapType = MapType.normal; // Chuyển về bản đồ thường
  }
}
