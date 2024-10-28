import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:map/bloc/map/map_event.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/token_response.dart';
import 'package:map/entity/travel_mode_enum.dart';
import 'package:map/entity/user.dart';
import 'package:map/main.dart';
import 'package:map/repository/token_repository.dart';
import 'package:map/service/place_search.dart';
import 'package:map/service/user_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../entity/place_type.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final UserService _userService = getIt<UserService>();
  final TokenRepo _tokenRepo = getIt<TokenRepo>();
  final PlaceSearch _placeSearch = getIt<PlaceSearch>();
  late User _user;
  late List<User> _friends = [];
  // late UserMove _userMove;
  late User? _friendTapped= null;
  late TokenResponse? _tokenResponse = null;
  late StompClient _client;
  late GoogleMapController? _googleMapController;
  late LocationData _currentPosition;
  late List<Marker> _markerUsers;
  late final Set<Marker> _markersPlace = {};
  late Marker _placeSearchMarker = const Marker(markerId: MarkerId(''));
  late MapType _currentMapType = MapType.normal;
  final Location _location = Location();
  late bool _isFollowCamera = true;
  late double _angelView = 0;
  late double _zoom = 16.0;
  late Place? _place = null;
  late bool _trafficEnabled = false;
  late bool _isTrackingDirection = false;
  late DirectionInfo? _directionInfo = null; // Thông tin đường đi
  late bool _isJourneyStarted = false;
  late String _query = '';
  late List<Place> _placesByNear = [];
  late bool _isLoading = false;
  late PlaceTypes _searchByNearSelectedType = PlaceTypes.none;
  late VehicleType _vehicleType = VehicleType.TWO_WHEELER;
  late bool _isEnabledSelectLocation = false;

  MapBloc() : super(LoadingMapState()) {
    on<InitMapEvent>((event, emit) async {
      await _init(emit);
    });
    // tim kiem dia diem
    on<FoundLocationEvent>((event, emit) async {
      await _foundLocationSearch(emit, event.place);
    });
    // Lấy thông tin google map controller
    on<LoadedMapControllerEvent>((event, emit) async {
      await _loadedMapControllerState(emit, event);
    });
    // lấy vị trí hiện tại
    on<CurrentLocationEvent>((event, emit) async {
      await _getCurrentLocation(emit);
    });
    // Di chuyển camera
    on<MapCameraMoveEvent>((event, emit) async {
      _isFollowCamera = _isTrackingDirection;
    });
    // chỉ đường
    on<DirectionEvent>((event, emit) async {
      await _direction(emit, event.origin, event.destination, event.place,
          VehicleType.TWO_WHEELER);
    });
    // bat dau theo doi duong di
    on<StartTrackingDirectionEvent>((event, emit) async {
      await _startTrackingDirection(event.directionInfo, emit);
    });
    // thay đổi chi tiết  map : tình trạng giao thng /..
    on<ChangeMapDetailEvent>((event, emit) async {
      await _changeMapDetail(emit, event.trafficEnabled);
    });
    // thay đổi kiểu  bản đồ : bản đồ đường, bản đồ vệ tinh,..
    on<ChangeMapTypeEvent>((event, emit) async {
      await _changeMapType(emit, event.mapType);
    });
    //Cập nhật vị trí
    on<LocationChangedEvent>((event, emit) async {
      await _updateLocation(emit, event.currentLocation);
    });
    // tìm kiếm địa điểm lân cận theo loại: nhà hàng, quán cafe, trường học, bệnh viện,..
    on<FindNearByTypeEvent>((event, emit) async {
      await _findByNearByType(event.type, event.locationData, emit);
    });
    // khi click vào marker place
    on<MarkerTappedEvent>((event, emit) async {
      await _markerTapped(emit, event.place);
    });
    // khi kết thúc chỉ đường xóa tất cả marker
    on<CompleteDirectionEvent>((event, emit) async {
      await _removeAllPlaceMarkers(emit);
    });
    //thay đổi loại phương tiện
    on<ChangeTransportModeEvent>((event, emit) async {
      await _changeTransportMode(emit, event.vehicleType);
    });
    //chon dia diem tren ban do
    on<SelectLocationEvent>((event, emit) async {
      await _enableSelectLocation(emit, event.isEnabledSelectLocation);
    });
    // sau khi da chon dia diem tren ban do
    on<SelectedLocationEvent>((event, emit) async {
      await _selectedLocation(emit, event.location);
    });
    // update marker khi friend di chuyen
    on<UpdateMarkersEvent>((event, emit) async {
      _emitLoadedMapState(emit);
    });
    // su kien khi nguoi dung tap vao icon ban be tren ban do
    on<MarkerFriendTappedEvent>((event, emit) async {
      await  _markerFriendTapped(emit, event.friend);
    });
    // su kien dong cua so friend
    on<CloseFriendTappedEvent> ((event, emit) async {
      _friendTapped=null;
      _emitLoadedMapState(emit);
    });
    add(InitMapEvent());
  }
  Future<void> _markerFriendTapped(Emitter<MapState> emit, User friend) async {
    _friendTapped=friend;
    _emitLoadedMapState(emit);
  }

  Future<void> _selectedLocation(
      Emitter<MapState> emit, LatLng location) async {
    await _removeAllPlaceMarkers(emit);
    _isLoading = true;
    _emitLoadedMapState(emit);
    DirectionInfo directionInfo = await _placeSearch.getPolylinePoints(
        LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        location);
    _directionInfo = directionInfo;
    _place = Place(
        placeId: '1',
        name: 'Điểm đến',
        formattedAddress: '',
        latitude: location.latitude,
        longitude: location.longitude);
    _markersPlace.add(Marker(
      onTap: () {
        add(MarkerTappedEvent(_place!));
      },
      markerId: MarkerId(_place!.placeId),
      position: location,
      infoWindow: InfoWindow(title: _place!.name),
      icon: BitmapDescriptor.defaultMarker,
    ));
    _isLoading = false;
    _emitLoadedMapState(emit);
    _zoomToFit(LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        location);
  }

  // zoom để nhìn thấy điểm đầu và điểm kết thúc
  Future<void> _zoomToFit(LatLng startPoint, LatLng endPoint) async {
    if (_googleMapController != null) {
      // Tạo LatLngBounds từ điểm bắt đầu và điểm kết thúc
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          startPoint.latitude < endPoint.latitude
              ? startPoint.latitude
              : endPoint.latitude,
          startPoint.longitude < endPoint.longitude
              ? startPoint.longitude
              : endPoint.longitude,
        ),
        northeast: LatLng(
          startPoint.latitude > endPoint.latitude
              ? startPoint.latitude
              : endPoint.latitude,
          startPoint.longitude > endPoint.longitude
              ? startPoint.longitude
              : endPoint.longitude,
        ),
      );

      // Tạo CameraUpdate để điều chỉnh zoom và di chuyển bản đồ
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(
          bounds, 50); // Thêm padding cho thoải mái
      await _googleMapController?.animateCamera(cameraUpdate);
    }
  }

  Future<void> _enableSelectLocation(
      Emitter<MapState> emit, bool isEnabledSelectLocation) async {
    _isEnabledSelectLocation = isEnabledSelectLocation;
    _emitLoadedMapState(emit);
  }

  Future<void> _changeTransportMode(
      Emitter<MapState> emit, VehicleType vehicleType) async {
    _vehicleType = vehicleType;
    await _direction(
        emit,
        LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        LatLng(_place!.latitude, _place!.longitude),
        _place!,
        vehicleType);
    _emitLoadedMapState(emit);
  }

  Future<void> _markerTapped(Emitter<MapState> emit, Place place) async {
    _directionInfo = null;
    _emitLoadedMapState(emit);
    _place = place;
    _emitLoadedMapState(emit);
  }

  Future<void> _updateLocation(
      Emitter<MapState> emit, LocationData locationData) async {
    await _updateUserLocation(locationData);
    print("update location ${locationData.latitude} ${locationData.longitude}");
    _emitLoadedMapState(emit);
  }

  Future<void> _changeMapType(Emitter<MapState> emit, MapType mapType) async {
    _currentMapType = mapType;
    _emitLoadedMapState(emit);
  }

  Future<void> _changeMapDetail(
      Emitter<MapState> emit, bool trafficEnabled) async {
    _trafficEnabled = trafficEnabled;
    _emitLoadedMapState(emit);
  }

  Future<void> _removeAllPlaceMarkers(Emitter<MapState> emit) async {
    _isTrackingDirection = false;
    _place = null;
    _directionInfo = null;
    _isJourneyStarted = false;
    _searchByNearSelectedType = PlaceTypes.none;
    _query = '';
    _vehicleType = VehicleType.TWO_WHEELER;
    _markersPlace.clear();
    _isEnabledSelectLocation = false;
    _placesByNear.clear();
    _angelView = 0;
    _friendTapped=null;
    _animateMapCamera(
        target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        zoom: 16);
    _emitLoadedMapState(emit);
  }

  Future<void> _findByNearByType(PlaceTypes type, LocationData locationData,
      Emitter<MapState> emit) async {
    if (_searchByNearSelectedType == type) {
      await _removeAllPlaceMarkers(emit);
      _emitLoadedMapState(emit);
      return;
    }
    _isLoading = true;
    _emitLoadedMapState(emit);
    final places =
        await _placeSearch.searchByNearByType(locationData, type, 5000);
    _placesByNear = places;
    _query = "Tìm thấy ${places.length} địa điểm";
    _place = null;
    _searchByNearSelectedType = type;
    _markersPlace.clear();
    for (var element in places) {
      _markersPlace.add(Marker(
        onTap: () {
          add(MarkerTappedEvent(element));
        },
        markerId: MarkerId(element.placeId),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(title: element.name),
        icon: BitmapDescriptor.defaultMarker,
      ));
    }
    _animateMapCamera(
        target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        zoom: 13);
    _isLoading = false;
    _emitLoadedMapState(emit);
  }

  Future<void> _startTrackingDirection(
      DirectionInfo directionInfo, Emitter<MapState> emit) async {
    _emitLoadedMapState(emit);
    _isTrackingDirection = true;
    _angelView = 45;
    _isFollowCamera = true;
    _zoom = 19.0; //zoom càng lớn thì camera càng gần
    _isJourneyStarted = true;
    double bearing = _currentPosition.heading ?? 0;
    _animateMapCamera(
        target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        zoom: _zoom,
        heading: bearing,
        angelView: _angelView);
    _emitLoadedMapState(emit);
  }

  void _emitLoadedMapState(Emitter<MapState> emit) {
    List<Marker> markers = [];
    markers.addAll(_markerUsers);
    markers.addAll(_markersPlace);
    emit(LoadedMapState(_currentPosition, markers, _currentMapType,
        _trafficEnabled, _isFollowCamera,
        googleMapController: _googleMapController,
        query: _query,
        isLoading: _isLoading,
        isJourneyStarted: _isJourneyStarted,
        directionInfo: _directionInfo,
        place: _place,
        vehicleType: _vehicleType,
        searchByNearSelectedType: _searchByNearSelectedType,
        isEnabledSelectLocation: _isEnabledSelectLocation,friendTapped: _friendTapped));
  }

  Future<void> _animateMapCamera(
      {required LatLng target,
      required double zoom,
      double? heading,
      double? angelView}) async {
    await _googleMapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: target,
            zoom: zoom,
            tilt: angelView ?? 0,
            bearing: heading ?? 0),
      ),
    );
  }

  Future<void> _direction(Emitter<MapState> emit, LatLng origin,
      LatLng destination, Place place, VehicleType vehicleType) async {
    _isLoading = true;
    _emitLoadedMapState(emit);
    // Tạo đường đi giữa 2 điểm
    try {
      DirectionInfo directionInfo = await _placeSearch
          .getPolylinePoints(origin, destination, mode: vehicleType);
      _directionInfo = directionInfo;
      _isLoading = false;
      _emitLoadedMapState(emit);
      _zoomToFit(origin, destination);
      return;
    } catch (e) {
      emit(MapErrorState("Không thể lấy thông tin chỉ đường: ${e.toString()}"));
    }
  }

  // tìm thấy địa điểm và di chuyển camera tới địa điểm đó
  Future<void> _foundLocationSearch(Emitter<MapState> emit, Place place) async {
    _markersPlace.clear();
    _placeSearchMarker = Marker(
      markerId: MarkerId(place.placeId),
      position: LatLng(place.latitude, place.longitude),
      infoWindow: InfoWindow(title: place.name),
      icon: BitmapDescriptor.defaultMarker,
    );
    _markersPlace.add(_placeSearchMarker);
    _query = place.name;
    _place = place;
    _animateMapCamera(
        target: LatLng(place.latitude, place.longitude), zoom: 14.0);
    _emitLoadedMapState(emit);
  }

  //khi controller của map load thì gán lại controller cho biến _googleMapController
  Future<void> _loadedMapControllerState(
      Emitter<MapState> emit, LoadedMapControllerEvent event) async {
    _googleMapController = event.googleMapController;
    for(Marker m in _markerUsers){
      _googleMapController!.showMarkerInfoWindow(m.markerId);
    }
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // Cập nhật vị trí khi có sự thay đổi
      add(LocationChangedEvent(currentLocation));
    });
  }

  Future<void> _updateUserLocation(LocationData currentLocation) async {
    _currentPosition = currentLocation; // Cập nhật vị trí hiện tại
    //hướng của người dùng
    double? bearing = currentLocation.heading;
    // Điều hướng camera tới vị trí mới
    if (_isFollowCamera) {
      _animateMapCamera(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: _zoom,
          heading: bearing,
          angelView: _angelView);
    }
    // Cập nhật vị trí của người dùng
    _user.longitude = currentLocation.longitude!;
    _user.latitude = currentLocation.latitude!;
    _user.speed = currentLocation.speed??0;
    _client.send(
        destination: '/app/on-move',
        headers: {
          'Content-type': 'application/json', // Đặt tiêu đề là JSON
          'Authorization': 'Bearer ${_tokenResponse?.accessToken}'
        },
        body: jsonEncode(_user.toMap()));
  }

  void _initWebsocket() {
    _client = StompClient(
        config: StompConfig(
      url: "ws://192.168.1.242:8080/ws?token=${_tokenResponse?.accessToken}",
      onConnect: _onConnect,
      onWebSocketError: (dynamic error) =>
          throw Exception("error connect $error"),
    ));
    _client.activate();
  }

  void _onConnect(StompFrame frame) {
    print(
        "----------------------------------------------------------------------");
    _client.subscribe(
        headers: {'Authorization': 'Bearer ${_tokenResponse?.accessToken}'},
        destination: '/user/private/friend-location',
        callback:onListenWs);
  }

  void onListenWs(StompFrame frame) {
    if(frame.body != null){
      User userFriend=  User.fromMap(jsonDecode(frame.body!));
      for(int i=0;i<_markerUsers.length;i++){
        if(_markerUsers[i].markerId.value==userFriend.googleId){
          BitmapDescriptor bitmapDescriptor = _markerUsers[i].icon;
          _markerUsers[i]=Marker(
            markerId: MarkerId(userFriend.googleId),
            position: LatLng(userFriend.latitude, userFriend.longitude),
            infoWindow: InfoWindow(title: "${userFriend.name}, speed: ${_convertMsToKmh(userFriend.speed)}km/h, distance: ${_calculateDistance(_currentPosition.latitude!,_currentPosition.longitude!,userFriend.latitude,userFriend.longitude)}m"),
            icon:bitmapDescriptor,
          );
        }
      }
      add(UpdateMarkersEvent()); // Kích hoạt sự kiện để cập nhật bản đồ
    }
  }
  int _convertMsToKmh(double speedMs) {
    return (speedMs * 3.6).round();
  }
  int _calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
    const double earthRadius = 6371000; // Bán kính trái đất (mét)

    double dLat = _degreeToRadian(endLatitude - startLatitude);
    double dLon = _degreeToRadian(endLongitude - startLongitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(startLatitude)) *
            cos(_degreeToRadian(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (earthRadius * c).round();
  }

  double _degreeToRadian(double degree) {
    return degree * pi / 180;
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
    _friends= await _userService.getAllFriends();
    if (user == null) {
      emit(LoadingMapState());
      return;
    }
    _tokenResponse = await _tokenRepo.getToken();
    if (_tokenResponse == null) {
      emit(MapErrorState("Token không tồn tại"));
      return;
    }

    List<Marker> markers = await _initMarker(user,_friends, currentLocation);
    _markerUsers = markers;
    _user = user;
    // _userMove = UserMove.fromUser(user);
    _currentPosition = currentLocation;
    _trafficEnabled = false;
    // interval là thơì gian cập nhật, distanceFilter là khoảng cách cập nhật
    // sau 2s nó sẽ kiểm tra cập nhật, nếu di chuyển 20m thì Mới thông báo
    _location.changeSettings(
        interval: 1000, distanceFilter: 5, accuracy: LocationAccuracy.high);
    emit(LoadedMapState(currentLocation, markers, _currentMapType,
        _trafficEnabled, _isFollowCamera,
        googleMapController: null));
    _initWebsocket();
  }

  Future<List<Marker>> _initMarker(user, friends, LocationData currentLocation) async {
    const LatLng hoangSa = LatLng(16.1, 111.5); // Tọa độ gần Hoàng Sa
    const LatLng truongSa = LatLng(12.5, 114.5); // Tọa độ gần Trường Sa

    // Sử dụng Future.wait để khởi tạo Marker của bạn bè đồng thời
    List<Future<Marker>> futureMarkers = friends.map<Future<Marker>>((element) async {
      return Marker(
        markerId: MarkerId(element.googleId),
        position: LatLng(element.latitude, element.longitude),
        infoWindow: InfoWindow(title: "${element.name}, speed: ${element.speed}"),
        icon: await _convertAvatarUrlToBitMapDescriptor(element.avatarUrl),
        onTap: () {
          // Khi người dùng nhấn vào Marker, hiển thị thông tin
          add(MarkerFriendTappedEvent(element));
        },
      );
    }).toList();

    // Chờ tất cả các Future hoàn thành và lấy danh sách Marker
    List<Marker> friendMarkers = await Future.wait(futureMarkers);

    // Thêm Marker cho Hoàng Sa và Trường Sa
    List<Marker> staticMarkers = await _getStaticMarkers(hoangSa, truongSa);

    // Kết hợp tất cả các Marker
    return [...friendMarkers, ...staticMarkers];
  }

  Future<List<Marker>> _getStaticMarkers(LatLng hoangSa, LatLng truongSa) async {
    return [
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
    ];
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
    if (_isTrackingDirection) {
      _zoom = _zoom == 19.0 ? 14.0 : 19.0;
      _angelView = _zoom == 19.0 ? 45 : 0;
    } else {
      _zoom = _zoom == 16.0 ? 19.0 : 16.0;
      _angelView = _angelView == 0 ? 45 : 0;
    }
    _isFollowCamera = true;
    final bearing = _currentPosition.heading ?? 0;
    _animateMapCamera(
        target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
        zoom: _zoom,
        angelView: _angelView,
        heading: bearing);
  }

  Future<BitmapDescriptor> _convertAvatarUrlToBitMapDescriptor(String url) async {
    // Tải ảnh từ URL
    if (url.isEmpty) {
      return BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(35, 35)),
        'assets/icons/user-location.png',
      );
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Uint8List imageData = response.bodyBytes;

      // Tải dữ liệu ảnh thành `ui.Image`
      final ui.Codec codec = await ui.instantiateImageCodec(imageData, targetWidth: 35, targetHeight: 35);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      // Khởi tạo `PictureRecorder` và `Canvas`
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final double size = 35.0;

      // Vẽ hình tròn
      final Paint paint = Paint()..color = Colors.transparent;
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paint);

      // Tạo `Path` cho hình tròn để cắt ảnh
      final Path clipPath = Path()..addOval(Rect.fromLTWH(0.0, 0.0, size, size));
      canvas.clipPath(clipPath);

      // Vẽ ảnh đã tải lên `Canvas`
      paint.color = Colors.white; // Bạn có thể thay đổi màu nền (nếu muốn)
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        Rect.fromLTWH(0, 0, size, size),
        paint,
      );

      // Chuyển `Picture` thành `Image`
      final ui.Image finalImage = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());

      // Chuyển đổi `Image` thành `ByteData`
      final ByteData? byteData = await finalImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to ByteData');
      }

      // Chuyển đổi `ByteData` thành `Uint8List`
      final Uint8List finalImageData = byteData.buffer.asUint8List();

      // Trả về `BitmapDescriptor` từ dữ liệu hình ảnh
      return BitmapDescriptor.bytes( finalImageData);
    } else {
      return BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(35, 35)),
        'assets/icons/user-location.png',
      );
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
