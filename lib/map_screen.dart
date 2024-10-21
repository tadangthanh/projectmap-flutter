import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/bloc/map/map_bloc.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/entity/place.dart';

import 'bloc/map/map_event.dart';
import 'common_view/appbar_search.dart';
import 'common_view/full_screen_image.dart';

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  bool _isNavigationIcon = false;

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
              title: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  // suffixIcon: Icon(Icons.search),
                  hintText: state.place != null
                      ? state.place?.name
                      : 'Tìm kiếm địa điểm',
                  border: InputBorder.none,
                ),
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                  if (result != null) {
                    final place = result as Place;
                    BlocProvider.of<MapBloc>(context)
                        .add(FoundLocationEvent(place));
                  }
                },
              ),
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  // Navigator.pop(context);
                },
              ),
              actions: _actions(context),
            ),
            body: Stack(
              children: [
                // Bản đồ
                GoogleMap(
                  onTap: (latLng) {},
                  mapToolbarEnabled: false,
                  buildingsEnabled: true,
                  trafficEnabled: state.trafficEnabled,
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
                  polylines: state.directionInfo != null
                      ? {state.directionInfo!.polyline} // Nếu directionInfo khác null, thêm polyline vào tập hợp
                      : {}, // Nếu null, trả về tập hợp rỗng
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
                        filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                        // Làm mờ
                        child: Container(
                          color: Colors.black
                              .withOpacity(0.2), // Nền màu tối với độ mờ
                        ),
                      ),
                    ),
                  ),
                // Nút mở panel
                Positioned(
                  top: 26,
                  right: 26,
                  child: _typeMapButton(),
                ),
                // icon định vị vị trí hiện tại
                Positioned(
                  bottom: 100,
                  right: 25,
                  child: _floatingActionButtons(context),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 150),
                  // Tăng tốc độ trượt lên
                  bottom: _isPanelOpen ? 0 : -450,
                  // Chiều cao panel
                  left: 0,
                  right: 0,
                  child: _mapMenu(context, state),
                ),
                state.place != null
                    ? _draggableWidget(context, state)
                    : const SizedBox(),
              ],
            ),
          );
        }
        return const SizedBox();
      }),
    );
  }

  Widget _draggableWidget(context, state) {
    Place place = state.place;
    return DraggableScrollableSheet(
      initialChildSize: 0.4, // Kích thước ban đầu
      minChildSize: 0.1, // Kích thước tối thiểu
      // maxChildSize: 0.5, // Kích thước tối đa
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        child: Text(
                          place.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        place.formattedAddress,
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text('Khoảng cách: ${place.directionInfo.distance} - Thời gian: ${place.directionInfo.duration}',style: const TextStyle(color: Colors.black),),
                      // Thêm nhiều widget khác vào đây
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(
                                  Colors.blueAccent), // Màu nền nút
                              foregroundColor: WidgetStateProperty.all(
                                  Colors.blueAccent), // Màu văn bản và icon
                            ),
                            onPressed: () {
                              BlocProvider.of<MapBloc>(context).add(
                                  DirectionEvent(
                                      LatLng(state.locationData.latitude!,
                                          state.locationData.longitude!),
                                      LatLng(place.latitude, place.longitude)));
                              // Hành động khi nhấn nút
                            },
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/icons/direction.png',
                                  width: 20,
                                  height: 20,
                                  color: Colors.white, // Đặt màu icon là trắng
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Đường đi',
                                  style: TextStyle(
                                      color: Colors
                                          .white), // Đặt màu text là trắng
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Wrap(
                          spacing: 8.0, // Khoảng cách ngang giữa các phần tử
                          children: [
                            for (var photo in place.photoReferences)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.transparent),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FullScreenImage(
                                            imageUrl:
                                                photo), // Chuyển đến màn hình ảnh lớn
                                      ),
                                    );
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    // Thay đổi giá trị để điều chỉnh độ bo
                                    child: Image.network(
                                      photo,
                                      width: MediaQuery.of(context).size.width / 3 - 16,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () {
                    // Hành động khi nhấn nút đóng
                    // Navigator.of(context).pop(); // Hoặc phương thức khác để đóng
                  },
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Icon(
                  Icons.drag_handle, // Biểu tượng kéo
                  size: 30, // Kích thước biểu tượng đánh dấu
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapMenu(context, state) {
    return Container(
      height: 400, // Chiều cao của panel
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          //header and close button
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
          // Danh sach cac loai ban do
          _listMapType(context, state),
          Container(
            height: 0.5, // Độ dày của đường
            color: Colors.grey, // Màu sắc của đường
          ),
          //header
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
          _listMapDetail(context, state),
        ],
      ),
    );
  }

  Widget _listMapDetail(context, state) {
    return Wrap(
      spacing: 8.0, // Khoảng cách ngang giữa các phần tử
      runSpacing: 8.0, // Khoảng cách dọc giữa các dòng
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 3 -
              16, // Điều chỉnh kích thước phần tử
          child: _mapDetailElement(
              'Giao thông',
              'assets/icons/icon-map-traffic.png',
              state.trafficEnabled,
              state,
              context, () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapDetailEvent(!state.trafficEnabled));
          }),
        ),
      ],
    );
  }

  Widget _listMapType(context, state) {
    return Wrap(
      spacing: 8.0, // Khoảng cách ngang giữa các phần tử
      runSpacing: 8.0, // Khoảng cách dọc giữa các dòng
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 3 -
              16, // Chia mỗi phần tử thành 1/3 màn hình
          child: _typeMap('Mặc định', 'assets/icons/icon-map-normal.png',
              MapType.normal, state, context, () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapTypeEvent(MapType.normal));
          }),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3 -
              16, // Đảm bảo kích thước cho mỗi phần tử
          child: _typeMap('Vệ tinh', 'assets/icons/icon-map-satellite.png',
              MapType.hybrid, state, context, () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapTypeEvent(MapType.hybrid));
          }),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 3 -
              16, // Đảm bảo kích thước cho mỗi phần tử
          child: _typeMap('Địa hình', 'assets/icons/icon-map-terrain.png',
              MapType.terrain, state, context, () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapTypeEvent(MapType.terrain));
          }),
        ),
        // Thêm các phần tử khác nếu cần
      ],
    );
  }

  Widget _floatingActionButtons(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: 'location',
          backgroundColor: Colors.white,
          shape: const CircleBorder(),
          onPressed: () {
            _isNavigationIcon = !_isNavigationIcon;
            BlocProvider.of<MapBloc>(context).add(
                CurrentLocationEvent()); // Cập nhật lại vị trí hiện tại khi bấm nút
          },
          child: !_isNavigationIcon
              ? Image.asset(
                  'assets/icons/navigation.png',
                  color: Colors.blue,
                  width: 20,
                  height: 20,
                )
              : Image.asset(
                  'assets/icons/compass.png',
                  color: Colors.blue,
                  width: 30,
                  height: 30,
                ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _typeMapButton() {
    return Container(
      width: 50,
      decoration: const BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
          tooltip: "Loại bản đồ",
          heroTag: 'panel',
          shape: const CircleBorder(),
          onPressed: _togglePanel,
          child: Image.asset(
            'assets/icons/type-map-button.png',
            color: Colors.black, // Đặt màu icon là đen
            width: 25, // Điều chỉnh chiều rộng
            height: 25, // Điều chỉnh chiều cao
            fit: BoxFit.contain, // Đảm bảo ảnh được chứa trong widget
          )),
    );
  }

  List<Widget> _actions(context) {
    return [
      Container(
        margin: const EdgeInsets.only(right: 16),
        child: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {},
        ),
      ),
    ];
  }

  Widget _typeMap(title, String assetIconUrl, mapType, state, context,
      Function()? function) {
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
              assetIconUrl, // Đường dẫn đến hình ảnh bản đồ
              height: 45, // Chiều cao của hình ảnh
              width: 45, // Chiều rộng của hình ảnh
            ),
          ),
          const SizedBox(height: 8), // Khoảng cách giữa hình ảnh và văn bản
          // Văn bản mô tả
          Text(
            title,
            style: TextStyle(
                fontSize: 12,
                color: mapType == state.currentMapType ? Colors.blue : null),
          ),
        ],
      ),
      onTap: () {
        // BlocProvider.of<MapBloc>(context).add(ChangeMapTypeEvent(mapType));
        function!();
      },
    );
  }

  Widget _mapDetailElement(title, String assetIconUrl, isEnabled, state,
      context, Function()? function) {
    return ListTile(
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Căn giữa nội dung
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Kiểm tra xem currentMapType có phải là MapType.hybrid không
          Container(
            decoration: BoxDecoration(
              border: isEnabled == true
                  ? Border.all(
                      color: Colors.blue,
                      width: 3) // Viền xanh nếu loại bản đồ là hybrid
                  : null,
              borderRadius: BorderRadius.circular(8), // Bo tròn các góc
            ),
            child: Image.asset(
              assetIconUrl, // Đường dẫn đến hình ảnh bản đồ
              height: 45, // Chiều cao của hình ảnh
              width: 45, // Chiều rộng của hình ảnh
            ),
          ),
          const SizedBox(height: 8), // Khoảng cách giữa hình ảnh và văn bản
          // Văn bản mô tả
          Text(
            title,
            style: TextStyle(
                fontSize: 12, color: isEnabled == true ? Colors.blue : null),
          ),
        ],
      ),
      onTap: () {
        // BlocProvider.of<MapBloc>(context).add(ChangeMapTypeEvent(mapType));
        function!();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _mapBloc.close();
  }
}
