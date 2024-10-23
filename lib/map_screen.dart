import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/bloc/map/map_bloc.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/bloc/search/search_bloc.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/place_type.dart';

import 'bloc/map/map_event.dart';
import 'common_view/appbar_search.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final MapBloc _mapBloc = MapBloc();
  final SearchBloc _searchBloc = SearchBloc();
  late AnimationController _controller;
  bool _isPanelOpen = false;
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController(); // Thêm controller cho DraggableScrollableSheet
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
        } else if (state is MapErrorState) {
          _alertDialog(context, state);
        } else if (state is LoadedMapState) {
          return Scaffold(
            appBar: AppBar(
              title: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: state.query.trim().isNotEmpty
                      ? state.query
                      : 'Tìm kiếm địa điểm',
                  border: InputBorder.none,
                ),
                onTap: () async {
                  BlocProvider.of<MapBloc>(context)
                      .add(CompleteDirectionEvent());
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
                      ? state.directionInfo!
                          .polyline // Nếu directionInfo khác null, thêm polyline vào tập hợp
                      : {},
                  // Nếu null, trả về tập hợp rỗng
                  onMapCreated: (controller) {
                    BlocProvider.of<MapBloc>(context)
                        .add(LoadedMapControllerEvent(controller));
                  },
                  onCameraMove: (position) {
                    BlocProvider.of<MapBloc>(context).add(MapCameraMoveEvent());
                  },
                ),
                // Hiển thị loading khi đang tải đường đi
                if (state.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                Positioned(
                    child:
                        // Nút tìm kiếm trạm xăng
                        Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // tìm trạm xăng gần nhất
                        _customButton(
                          icon: Icons.local_gas_station,
                          label: 'Trạm xăng',
                          onPressed: () {
                            BlocProvider.of<MapBloc>(context).add(
                                FindNearByTypeEvent(PlaceTypes.gas_station,
                                    state.locationData));
                          },
                        ),
                        // tìm trạm sửa xe gần nhất\
                        _customButton(
                          icon: Icons.build,
                          label: 'Trạm sửa xe',
                          onPressed: () {
                            // BlocProvider.of<MapBloc>(context).add(FindRepairStationEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                )),
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
                  top: 100,
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
                state.query.isNotEmpty && state.place != null
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

  Widget _customButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color buttonColor = Colors.white,
    Color iconColor = Colors.blue,
    Color textColor = Colors.black,
    double borderRadius = 12.0,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(-3, -3),
          ),
        ],
      ),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: buttonColor, // Nền nút
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius), // Bo tròn góc
          ),
        ),
        onPressed: onPressed, // Hành động khi click
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          // Căn giữa các phần tử trong nút
          children: [
            Icon(
              icon,
              size: 18,
              color: iconColor, // Màu của icon
            ),
            const SizedBox(width: 8), // Khoảng cách giữa icon và text
            Text(
              label,
              style: TextStyle(
                fontSize: 11, // Tăng kích thước font cho dễ đọc hơn
                fontWeight: FontWeight.w600, // Đặt độ dày cho chữ
                color: textColor, // Màu chữ
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _draggableWidget(context, state) {
    Place place = state.place;

    return DraggableScrollableSheet(
      controller: _draggableScrollableController,
      initialChildSize: 0.4,
      minChildSize: 0.1,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDragHandle(),
                  const SizedBox(height: 10),
                  _buildPlaceDetails(context, state, place),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

// Widget để hiển thị thông tin của một Place
  Widget _buildPlaceDetails(BuildContext context, state, Place place) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên của địa điểm
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Địa chỉ của địa điểm
          place.formattedAddress.trim().isNotEmpty
              ? Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        place.formattedAddress,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          const SizedBox(height: 20),
          // Nút hành động cho hành trình
          _buildJourneyActionButtons(context, state, place),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildPlaceName(Place place) {
    return Text(
      place.name,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPlaceAddress(Place place) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.blue),
        const SizedBox(width: 8), // Khoảng cách giữa icon và text
        Expanded(
          child: Text(
            place.formattedAddress,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJourneyActionButtons(BuildContext context, state, Place place) {
    // Hiển thị các nút dựa trên trạng thái hành trình
    if (!state.isJourneyStarted && state.directionInfo == null) {
      return _buildDirectionAndCancelButtons(context, state, place);
    } else if (state.directionInfo != null && !state.isJourneyStarted) {
      return _buildStartAndCancelButtons(context, state);
    } else if (state.isJourneyStarted) {
      return _buildCompleteButton(context, state);
    }

    return const SizedBox();
  }

  Widget _buildDirectionAndCancelButtons(
      BuildContext context, state, Place place) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _direction(context, state, 'Đường đi', 'assets/icons/direction.png',
            () {
          BlocProvider.of<MapBloc>(context).add(DirectionEvent(
            LatLng(state.locationData.latitude!, state.locationData.longitude!),
            LatLng(place.latitude, place.longitude),
            place,
          ));
        }),
        _direction(context, state, 'Hủy', 'assets/icons/cancel.png', () {
          BlocProvider.of<MapBloc>(context).add(CompleteDirectionEvent());
        }),
      ],
    );
  }

  Widget _buildStartAndCancelButtons(BuildContext context, state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _direction(context, state, 'Bắt đầu', 'assets/icons/navigation.png',
            () {
          _draggableScrollableController.animateTo(
            0.1, // Kích thước nhỏ nhất
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          BlocProvider.of<MapBloc>(context).add(
            StartTrackingDirectionEvent(state.directionInfo!),
          );
        }),
        _direction(context, state, 'Hủy', 'assets/icons/cancel.png', () {
          BlocProvider.of<MapBloc>(context).add(CompleteDirectionEvent());
        }),
      ],
    );
  }

  Widget _buildCompleteButton(BuildContext context, state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _direction(context, state, 'Hoàn thành', 'assets/icons/complete.png',
            () {
          BlocProvider.of<MapBloc>(context).add(CompleteDirectionEvent());
        }),
      ],
    );
  }

  Widget _direction(
      context, state, label, assetsUrlIcon, Function()? function) {
    return Row(
      children: [
        ElevatedButton(
          style: ButtonStyle(
            backgroundColor:
                WidgetStateProperty.all(Colors.blueAccent), // Màu nền nút
            foregroundColor: WidgetStateProperty.all(
                Colors.blueAccent), // Màu văn bản và icon
          ),
          onPressed: () {
            function!();
            // Hành động khi nhấn nút
          },
          child: Row(
            children: [
              Image.asset(
                assetsUrlIcon,
                width: 20,
                height: 20,
                color: Colors.white, // Đặt màu icon là trắng
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white), // Đặt màu text là trắng
              ),
            ],
          ),
        )
      ],
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
          elevation: 8,
          // Thêm hiệu ứng đổ bóng
          onPressed: () {
            _isNavigationIcon = !_isNavigationIcon;
            BlocProvider.of<MapBloc>(context).add(CurrentLocationEvent());
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
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(5, 5),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            blurRadius: 10,
            offset: Offset(-5, -5),
          ),
        ],
      ),
      child: FloatingActionButton(
        tooltip: "Loại bản đồ",
        heroTag: 'panel',
        onPressed: _togglePanel,
        backgroundColor: Colors.blue,
        child: Image.asset(
          'assets/icons/type-map-button.png',
          color: Colors.white,
          width: 25,
          height: 25,
        ),
      ),
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

  Widget _alertDialog(context, state) {
    return AlertDialog(
      title: const Text('Thông báo'),
      content: Text(state.message),
      actions: [
        TextButton(
          onPressed: () {
            BlocProvider.of<MapBloc>(context).add(InitMapEvent());
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapBloc.add(InitMapEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _mapBloc.close();
  }
}
