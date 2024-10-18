import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Location _location = Location();
  late GoogleMapController _googleMapController;
  late LocationData _currentPosition;
  Set<Marker> _markers = {}; // Để lưu trữ các marker trên bản đồ
  bool _isLoading = true; // Để kiểm soát hiển thị trong khi chờ lấy vị trí
  MapType _currentMapType = MapType.normal; // Kiểu bản đồ mặc định là bản đồ thường

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Lấy vị trí hiện tại khi ứng dụng khởi động
    _location.onLocationChanged.listen((LocationData currentLocation) {
      // Cập nhật vị trí khi có sự thay đổi
      _updateLocation(currentLocation);
    });
  }

  // Hàm lấy vị trí hiện tại của người dùng
  void _getCurrentLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Kiểm tra và yêu cầu bật dịch vụ vị trí
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Kiểm tra quyền truy cập vị trí
    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Lấy vị trí hiện tại
    _currentPosition = await _location.getLocation();

    // Cập nhật vị trí camera và thêm marker
    setState(() {
      _isLoading = false; // Đã lấy xong vị trí, ẩn loading
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
          infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
        ),
      );
    });

    // Điều hướng camera tới vị trí hiện tại
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
          zoom: 16.0,
        ),
      ),
    );
  }

  // Cập nhật vị trí khi có sự thay đổi
  void _updateLocation(LocationData currentLocation) {
    setState(() {
      _currentPosition = currentLocation; // Cập nhật vị trí hiện tại
      _markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
        ),
      );

      // Điều hướng camera tới vị trí mới
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 16.0,
          ),
        ),
      );
    });
  }

  // Hàm chuyển đổi kiểu bản đồ
  void _toggleMapType() {
    setState(() {
      // Chuyển đổi giữa bản đồ vệ tinh (hybrid) và bản đồ thường
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.hybrid // Sử dụng hybrid để giữ nhãn
          : MapType.normal; // Chuyển về bản đồ thường
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading khi đang lấy vị trí
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentPosition.latitude!, _currentPosition.longitude!),
          zoom: 16.0,
        ),
        myLocationEnabled: true, // Hiển thị vị trí của người dùng
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        markers: _markers, // Thêm marker lên bản đồ
        mapType: _currentMapType, // Áp dụng kiểu bản đồ hiện tại
        onMapCreated: (controller) => _googleMapController = controller,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _getCurrentLocation(); // Cập nhật lại vị trí hiện tại khi bấm nút
            },
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 10), // Khoảng cách giữa các nút
          FloatingActionButton(
            onPressed: _toggleMapType, // Chuyển đổi kiểu bản đồ
            child: const Icon(Icons.map), // Icon để người dùng biết là chuyển bản đồ
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }
}
