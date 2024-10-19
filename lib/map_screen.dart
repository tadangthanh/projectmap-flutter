import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:map/bloc/map/map_bloc.dart';
import 'package:map/bloc/map/map_state.dart';

import 'bloc/map/map_event.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapBloc _mapBloc = MapBloc();
  late AnimationController _controller;
  bool _isPanelOpen = false;

  void _togglePanel() {
    setState(() {
      _isPanelOpen = !_isPanelOpen;
      _isPanelOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeMapRenderer();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  void _initializeMapRenderer() {
    final GoogleMapsFlutterPlatform mapsImplementation =
        GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      mapsImplementation.useAndroidViewSurface = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _mapBloc,
      child: BlocBuilder<MapBloc, MapState>(builder: (context, state) {
        if (state is LoadingMapState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is LoadedMapState) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Bản đồ'),
            ),
            body: Center(
              child: Stack(
                children: [
                  // Bản đồ
                  GoogleMap(
                    buildingsEnabled: true,
                    trafficEnabled: true,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(state.locationData.latitude!,
                          state.locationData.longitude!),
                      zoom: 16.0,
                    ),
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    markers: state.markers,
                    mapType: state.currentMapType,
                    onMapCreated: (controller) {
                      BlocProvider.of<MapBloc>(context)
                          .add(LoadedMapControllerEvent(controller));
                    },
                    onCameraMove: (position) {
                      BlocProvider.of<MapBloc>(context)
                          .add(MapCameraMoveEvent());
                    },
                  ),

                  // Làm mờ bản đồ khi panel mở
                  if (_isPanelOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          // Đóng panel khi người dùng nhấn vào phần làm mờ
                          setState(() {
                            _isPanelOpen = false; // Đóng panel
                          });
                        },
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          // Làm mờ
                          child: Container(
                            color: Colors.black
                                .withOpacity(0.5), // Nền màu tối với độ mờ
                          ),
                        ),
                      ),
                    ),
                  // Nút mở panel
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      width: 40,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: FloatingActionButton(
                          shape: const CircleBorder(),
                          onPressed: _togglePanel,
                          child: Image.asset(
                            'assets/icons/stack.png',
                            color: Colors.black, // Đặt màu icon là đen
                            width: 25, // Điều chỉnh chiều rộng
                            height: 25, // Điều chỉnh chiều cao
                            fit: BoxFit
                                .contain, // Đảm bảo ảnh được chứa trong widget
                          )),
                    ),
                  ),
                  // icon định vị vị trí hiện tại
                  Positioned(
                    bottom: 100,
                    right: 25,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Transform.rotate(
                          angle: 40 *(3.14 /180),
                          child: FloatingActionButton(
                            backgroundColor: Colors.white,
                            shape: const CircleBorder(),
                            onPressed: () {
                              BlocProvider.of<MapBloc>(context).add(
                                  CurrentLocationEvent()); // Cập nhật lại vị trí hiện tại khi bấm nút
                            },
                            child: const Icon(Icons.navigation,color: Colors.blue,),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 150),
                    // Tăng tốc độ trượt lên
                    bottom: _isPanelOpen ? 0 : -300,
                    // Chiều cao panel
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 400, // Chiều cao của panel
                      color: Colors.white,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: const Text("Loại bản đồ"),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_outlined),
                                  onPressed: _togglePanel,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: _typeMap('Mặc định',
                                          MapType.normal, state, context)),
                                  Expanded(
                                      child: _typeMap('Vệ tinh', MapType.hybrid,
                                          state, context)),
                                  Expanded(
                                      child: _typeMap('Địa hình',
                                          MapType.terrain, state, context))
                                ],
                              )
                            ],
                          ),
                          Container(
                            height: 0.5, // Độ dày của đường
                            color: Colors.grey, // Màu sắc của đường
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: const Text("Chi tiết bản đồ"),
                                )
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: _typeMap('Mặc định',
                                          MapType.normal, state, context)),
                                  Expanded(
                                      child: _typeMap('Vệ tinh', MapType.hybrid,
                                          state, context)),
                                  Expanded(
                                      child: _typeMap('Địa hình',
                                          MapType.terrain, state, context))
                                ],
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        return const Text("ASdasds");
      }),
    );
  }

  Widget _typeMap(title, mapType, state, context) {
    Map<MapType, String> mapTypeIconAssets = {
      MapType.normal: 'assets/icons/icon-map-normal.png',
      MapType.hybrid: 'assets/icons/icon-map-satellite.png',
      MapType.terrain: 'assets/icons/icon-map-terrain.png',
    };
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiểm tra xem currentMapType có phải là MapType.hybrid không
          Container(
            decoration: BoxDecoration(
              border: state.currentMapType == mapType
                  ? Border.all(
                      color: Colors.blue,
                      width: 3) // Viền xanh nếu loại bản đồ là hybrid
                  : null,
              borderRadius: BorderRadius.circular(8), // Bo tròn các góc
            ),
            child: Image.asset(
              mapTypeIconAssets[mapType]!, // Đường dẫn đến hình ảnh bản đồ
              height: 40, // Chiều cao của hình ảnh
              width: 40, // Chiều rộng của hình ảnh
            ),
          ),
          const SizedBox(height: 8), // Khoảng cách giữa hình ảnh và văn bản
          // Văn bản mô tả
          Text(
            title,
            style: TextStyle(
                color: mapType == state.currentMapType ? Colors.blue : null),
          ),
        ],
      ),
      onTap: () {
        BlocProvider.of<MapBloc>(context).add(ChangeMapTypeEvent(mapType));
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _mapBloc.close();
  }
}
