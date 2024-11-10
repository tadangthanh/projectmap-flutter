import 'dart:ui';

import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map/bloc/map/map_bloc.dart';
import 'package:map/bloc/map/map_state.dart';
import 'package:map/common_view/loading.dart';
import 'package:map/dto/group_location_request.dart';
import 'package:map/dto/group_response_dto.dart';
import 'package:map/dto/location_dto.dart';
import 'package:map/dto/shared_location_request.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/place_type.dart';
import 'package:map/entity/travel_mode_enum.dart';
import 'package:map/entity/user.dart';

import 'bloc/map/map_event.dart';
import 'common_view/appbar_search.dart';
import 'entity/map_theme.dart';
import 'marker_info_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final MapBloc _mapBloc = MapBloc();
  late TabController _tabController;
  final TextEditingController _noteLocationController = TextEditingController();
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
    // Khởi tạo TabController với nhiều ticker
    _tabController = TabController(length: 3, vsync: this);

    // Lắng nghe sự kiện thay đổi tab
    _tabController.addListener(() {
      if (_tabController.index == _tabController.animation?.value) {
        // Nếu index của tab bằng giá trị của animation
        // Gửi sự kiện thay đổi loại phương tiện
        switch (_tabController.index) {
          case 0:
            _mapBloc.add(ChangeTransportModeEvent(VehicleType.DRIVE));
            break;
          case 1:
            _mapBloc.add(ChangeTransportModeEvent(VehicleType.TWO_WHEELER));
            break;
          case 2:
            _mapBloc.add(ChangeTransportModeEvent(VehicleType.WALK));
            break;
        }
      }
    });
  }

  bool _isNavigationIcon = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocProvider(
        create: (context) => _mapBloc,
        child: BlocBuilder<MapBloc, MapState>(builder: (context, state) {
          if (state is LoadingMapState) {
            return loading();
          } else if (state is MapErrorState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showAlert(context, state.message);
            });
          } else if (state is LoadedMapState) {
            if (state.message != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showAlert(context, state.message!);
              });
            }
            return Scaffold(
              // appBar: _buildAppBar(context, state),
              body: Stack(
                children: [
                  // Bản đồ
                  GoogleMap(
                    fortyFiveDegreeImageryEnabled: true,
                    style: state.style,
                    onTap: (latLng) {
                      BlocProvider.of<MapBloc>(context)
                          .add(LatLngTappedEvent(latLng));
                    },
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
                    markers: state.markers.toSet(),
                    mapType: state.currentMapType,
                    polylines: state.directionInfo != null
                        ? state.directionInfo!.polyline
                            .toSet() // Nếu directionInfo khác null, thêm polyline vào tập hợp
                        : {},
                    // Nếu null, trả về tập hợp rỗng
                    onMapCreated: (controller) {
                      BlocProvider.of<MapBloc>(context)
                          .add(MapControllerLoadedEvent(controller));
                    },
                    onCameraMove: (position) {
                      BlocProvider.of<MapBloc>(context)
                          .add(MapCameraMoveEvent());
                    },
                  ),
                  // Icon location ở giữa màn hình
                  state.isEnabledSelectLocation
                      ? Center(
                          child: Image.asset(
                            'assets/icons/location-select.png',
                            width: 30,
                            height: 30,
                          ),
                        )
                      : const SizedBox(),
                  // Hiển thị loading khi đang tải đường đi
                  if (state.isLoading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                        child: loading(),
                      ),
                    ),
                  Positioned(
                    top: 5,
                    left: 0,
                    right: 0,
                    child: !state.isEnabledSelectLocation
                        ? _buildTextFieldSearch(context, state)
                        : _buildBackSelectLocation(context, state),
                  ),
                  !state.isOnJourneyStarted && !state.isEnabledSelectLocation
                      ? Positioned(
                          top: 50,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildListShortcut(context, state),
                          ),
                        )
                      : const SizedBox(),
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
                    top: 150,
                    right: 26,
                    child: !state.isEnabledSelectLocation
                        ? _typeMapButton()
                        : const SizedBox(),
                  ),
                  // icon định vị vị trí hiện tại
                  !state.isEnabledSelectLocation && !state.isOnJourneyStarted
                      ? Positioned(
                          bottom: 50,
                          right: 0,
                          child: _floatingActionsButtonBuilder(context, state),
                        )
                      : const SizedBox(),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: _buttonOkBottom(context, state),
                  ),
                  // Panel trượt từ dưới lên
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    // Thêm đường cong cho hiệu ứng mượt hơn
                    bottom: _isPanelOpen ? 0 : -450,
                    // Chiều cao của panel khi đóng
                    left: 0,
                    right: 0,
                    child: _mapMenu(context, state),
                  ),
                  // state.query.isNotEmpty &&
                  state.place != null
                      ? _draggableWidget(context, state)
                      : const SizedBox(),
                  // Làm mờ bản đồ và xử lý nhấn bên ngoài _buildWidgetFriend
                  if (state.friendTapped != null ||
                      state.locationMarkerGroupTapped != null)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () {
                          // Gửi sự kiện để đóng _buildWidgetFriend
                          BlocProvider.of<MapBloc>(context)
                              .add(CloseFriendTappedEvent());
                        },
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Container(
                            color: Colors.black.withOpacity(0.4), // Màu nền mờ
                          ),
                        ),
                      ),
                    ),
                  // Hiển thị _buildWidgetFriend nếu friendTapped khác null
                  if (state.friendTapped != null)
                    _buildWidgetFriend(context, state),
                  // state.message != null
                  //     ? Center(
                  //   child: _showAlertDialog(state.message),
                  // )
                  //     : const SizedBox(),
                  // state.isEnableDeleteMarkerGroup
                  //     ? Center(
                  //   child: _showAlertDialog('Xóa thành công'),
                  // )
                  //     : const SizedBox(),
                  // Display location information only when locationMarkerGroupTapped is available
                  if (state.locationMarkerGroupTapped != null)
                    _buildLocationMarkerInfo(
                        state.locationMarkerGroupTapped!, context, () {
                      BlocProvider.of<MapBloc>(context).add(
                          DeleteLocationGroupEvent(
                              state.locationMarkerGroupTapped?.id ?? 0));
                    }, () {
                      BlocProvider.of<MapBloc>(context)
                          .add(CloseLocationMarkerGroupTappedEvent());
                    }),
                ],
              ),
            );
          }
          return const SizedBox();
        }),
      ),
    );
  }

  Widget _buildLocationMarkerInfo(LocationDto location, BuildContext context,
      VoidCallback onDelete, VoidCallback onClose) {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title with Location Name
              Text(
                '\u{1F4C4} ${location.name}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                '\u{1F4DD} ${location.description}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // Group Name
              if (location.groupName != null)
                Text(
                  '\u{1F465}: ${location.groupName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),

              const SizedBox(height: 8),

              // Created Date
              if (location.createdAt != null)
                Text(
                  '\u{1F4C5} : ${DateFormat('dd/MM/yyyy HH:mm').format(location.createdAt!)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

              const SizedBox(height: 8),

              // Created By
              if (location.createdBy != null)
                Text(
                  '\u{1F464}: ${location.createdBy}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),

              const SizedBox(height: 16),

              // Button Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onClose,
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      onDelete();
                      onClose();
                    },
                    child: const Text('Delete'),
                  ),
                  IconButton(
                      onPressed: () {
                        BlocProvider.of<MapBloc>(context)
                            .add(SelectedLocationEvent(location));
                        onClose();
                      },
                      icon: const Icon(
                        Icons.arrow_right_alt_outlined,
                        color: Colors.blueGrey,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListShortcut(context, state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          const SizedBox(width: 16), // Khoảng cách bên trái
          // tìm trạm xăng gần nhất
          _customButton(
            icon: Icons.local_gas_station,
            label: 'Trạm xăng',
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(FindNearByTypeEvent(
                  PlaceTypes.gas_station, state.locationData));
            },
            isSelected:
                state.searchByNearSelectedType == PlaceTypes.gas_station,
          ),
          const SizedBox(width: 5),
          // tìm trạm sửa xe gần nhất
          _customButton(
            icon: Icons.car_repair,
            label: 'Trạm sửa xe',
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(FindNearByTypeEvent(
                  PlaceTypes.car_repair, state.locationData));
            },
            isSelected: state.searchByNearSelectedType == PlaceTypes.car_repair,
          ),
          const SizedBox(width: 5),
          _customButton(
            icon: Icons.store,
            label: 'Tạp hóa',
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(FindNearByTypeEvent(
                  PlaceTypes.supermarket, state.locationData));
            },
            isSelected:
                state.searchByNearSelectedType == PlaceTypes.supermarket,
          ),
          const SizedBox(width: 5),
          _customButton(
            icon: Icons.local_police_outlined,
            label: 'Cảnh sát',
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(
                  FindNearByTypeEvent(PlaceTypes.police, state.locationData));
            },
            isSelected: state.searchByNearSelectedType == PlaceTypes.police,
          ),
          const SizedBox(width: 5),
          _customButton(
            icon: Icons.local_hospital,
            label: 'Dịch vụ y tế',
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(
                  FindNearByTypeEvent(PlaceTypes.hospital, state.locationData));
            },
            isSelected: state.searchByNearSelectedType == PlaceTypes.hospital,
          ),
          const SizedBox(width: 5),
          _customButton(
            icon: Icons.directions_bus,
            label: 'Bus',
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(FindNearByTypeEvent(
                  PlaceTypes.bus_station, state.locationData));
            },
            isSelected:
                state.searchByNearSelectedType == PlaceTypes.bus_station,
          ),
          const SizedBox(width: 16), // Khoảng cách bên phải
        ],
      ),
    );
  }

  Widget _buildWidgetFriend(BuildContext context, state) {
    // Lấy thông tin friend từ state
    final user = state.friendTapped;

    return Positioned(
      top: 100, // Vị trí của widget
      left: 20, // Vị trí của widget
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar của bạn bè
            CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(user.avatarUrl),
              onBackgroundImageError: (_, __) => const Icon(
                  Icons.person), // Hiển thị biểu tượng nếu ảnh không load được
            ),
            const SizedBox(height: 12),

            // Tên và email của bạn bè
            Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),

            // Thông tin tốc độ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                    Icons.battery_full, "Battery", "${user.batteryLevel}%"),
              ],
            ),
            const SizedBox(height: 5),

            // Thông tin vị trí
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(Icons.location_on, "Latitude",
                    user.latitude.toStringAsFixed(5)),
                const SizedBox(height: 5),
                _buildInfoRow(Icons.location_on, "Longitude",
                    user.longitude.toStringAsFixed(5)),
              ],
            ),
            const SizedBox(height: 12),

            // Khoảng cách
            _buildInfoRow(Icons.directions_walk, "Distance",
                "${user.distance.toStringAsFixed(2)} m"),
          ],
        ),
      ),
    );
  }

// Tiện ích để hiển thị thông tin dạng biểu tượng + nhãn + giá trị
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        SizedBox(width: 8),
        Text(
          "$label: ",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(value),
      ],
    );
  }

  Widget _customButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color buttonColor = Colors.white,
    Color textColor = Colors.black,
    double borderRadius = 16.0,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  Colors.blueAccent.shade200,
                  Colors.blue.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : buttonColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            // Bóng mờ nhẹ hơn để tạo sự tinh tế
            offset: const Offset(0, 4),
            // Bóng đổ xuống dưới một chút để tạo độ nổi
            blurRadius: 8, // Tăng độ mờ để bóng trông tự nhiên hơn
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.blue.withOpacity(0.2),
          // Hiệu ứng khi nhấn
          highlightColor: Colors.transparent,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    // Đặt độ dày chữ vừa phải để trông sang hơn
                    color: isSelected ? Colors.white : textColor,
                  ),
                ),
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
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
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, -7),
              ),
            ],
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildDragHandle(),
                      const SizedBox(height: 15),
                      _buildPlaceDetails(context, state, place),
                    ],
                  ),
                ),
              ),
              // Thêm nút X (đóng)
              Positioned(
                right: 16,
                top: 16,
                child: GestureDetector(
                  onTap: () {
                    BlocProvider.of<MapBloc>(context)
                        .add(CompleteDirectionEvent());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade200,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Widget để hiển thị thông tin của một Place
  Widget _buildPlaceDetails(BuildContext context, state, Place place) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên của địa điểm
          Text(
            place.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Địa chỉ của địa điểm
          place.formattedAddress.trim().isNotEmpty
              ? Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blueAccent),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        place.formattedAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
          const SizedBox(height: 25),
          state.directionInfo == null
              ? const SizedBox()
              : DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(
                            text: 'Ô tô',
                            icon: Icon(Icons.directions_car),
                          ),
                          Tab(
                            text: 'Xe máy',
                            icon: Icon(Icons.two_wheeler),
                          ),
                          Tab(
                            text: 'Đi bộ',
                            icon: Icon(Icons.directions_walk),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      state.isLoading
                          ? loading()
                          : SizedBox(
                              height: 70,
                              child: TabBarView(
                                controller: _tabController,
                                children: [
                                  _buildDistanceAndDurationWidgets(
                                      state.directionInfo?.distance,
                                      state.directionInfo?.duration),
                                  _buildDistanceAndDurationWidgets(
                                      state.directionInfo?.distance,
                                      state.directionInfo?.duration),
                                  _buildDistanceAndDurationWidgets(
                                      state.directionInfo?.distance,
                                      state.directionInfo?.duration),
                                ],
                              ),
                            ),
                    ],
                  ),
                ),
          const SizedBox(height: 25),
          // Nút hành động cho hành trình
          state.isLoading
              ? const SizedBox()
              : _buildJourneyActionButtons(context, state, place),
        ],
      ),
    );
  }

  Widget _buildDistanceAndDurationWidgets(String distance, String duration) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Khoảng cách & Thời gian dự kiến:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              "${(double.parse(distance) / 1000).toStringAsFixed(1)} km",
              style: const TextStyle(fontSize: 16),
            ),
            Row(
              children: [
                const SizedBox(width: 10),
                const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                ),
                Text(
                  () {
                    // Lấy số giây từ chuỗi và chuyển đổi sang double
                    double seconds = double.parse(duration.split("s")[0]);

                    // Chuyển từ giây sang giờ và phút
                    int hours = (seconds ~/ 3600);
                    int minutes = ((seconds % 3600) / 60).floor();

                    // Trả về chuỗi giờ và phút với định dạng phù hợp
                    if (hours > 0) {
                      return "$hours giờ $minutes phút";
                    } else {
                      return "$minutes phút";
                    }
                  }(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _transportOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        // Space between buttons
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
                child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black,
              size: 20,
            )),
            const SizedBox(height: 10),
            Expanded(
                child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            )),
          ],
        ),
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
    if (!state.isOnJourneyStarted && state.directionInfo == null) {
      return _buildDirectionAndMoreFeatureButtons(context, state, place);
    } else if (state.directionInfo != null && !state.isOnJourneyStarted) {
      return Column(
        children: [
          // // Nút chọn lộ trình cho các loại xe
          // _buildRouteSelectionButtons(context, state),
          // Nút bắt đầu và hủy
          _buildStartAndCancelButtons(context, state),
        ],
      );
    } else if (state.isOnJourneyStarted) {
      return _buildCompleteButton(context, state);
    }

    return const SizedBox();
  }

  void _addMarker(LatLng position) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarkerInfoScreen(
          onSave: (String name, String description,
              List<GroupResponseDto> sharedGroups) {
            List<int> groupIds = sharedGroups.map((e) => e.id!).toList();
            GroupLocationRequest groupLocationRequest = GroupLocationRequest(
              groupIds: groupIds,
              location: LocationDto(
                  latitude: position.latitude,
                  longitude: position.longitude,
                  name: name,
                  description: description),
            );
            _mapBloc.add(AddLocationToGroupEvent(groupLocationRequest));
          },
        ),
      ),
    );
  }

  Widget _buildDirectionAndMoreFeatureButtons(
      BuildContext context, state, Place place) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _directionFunctionButton(
            context, state, 'Đường đi', Icons.directions, Colors.blueAccent,
            () {
          BlocProvider.of<MapBloc>(context).add(DirectionEvent(
            LatLng(state.locationData.latitude!, state.locationData.longitude!),
            LatLng(place.latitude, place.longitude),
            place,
          ));
        }),
        // Nút More với PopupMenuButton để hiển thị các chức năng khác
        // PopupMenuButton<String>(
        //   child: const Row(
        //     children: [
        //       Text("Chia sẻ"),
        //       SizedBox(width: 5),
        //       Icon(Icons.arrow_outward, color: Colors.grey),
        //     ],
        //   ),
        //   onSelected: (value) {
        //     if (value == 'share') {
        //       _addMarker(LatLng(place.latitude, place.longitude));
        //     } else if (value == 'friend') {
        //    _showBottomMenu(context);
        //     }
        //   },
        //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        //     ..._buildPopupMenuItems(state),
        //   ],
        // ),
        TextButton(
            onPressed: () {
              _showBottomMenu(context, state);
            },
            child: const Row(
              children: [
                Text("Chia sẻ", style: TextStyle(color: Colors.grey)),
                SizedBox(width: 5),
                Icon(Icons.arrow_outward, color: Colors.grey),
              ],
            )),
      ],
    );
  }

  void _showBottomMenu(context, state) {
    List<User> friends = state.friends;
    User user = state.user!;
    Set<User> selectedFriends = {}; // Danh sách lưu các bạn bè đã chọn

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.avatarUrl),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteLocationController,
                    maxLength: 255,
                    decoration: const InputDecoration(
                      hintText: 'Hãy viết gì đó về địa điểm này...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Gửi cho tất cả những người trong danh sách selectedFriends
                      _sendSharedLocation(selectedFriends, state);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                    ),
                    child: const Text(
                      'Chia sẻ ngay',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chia sẻ cho bạn bè',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        User friend = friends[index];
                        bool isSelected = selectedFriends.contains(friend);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedFriends.remove(friend);
                                    } else {
                                      selectedFriends.add(friend);
                                    }
                                  });
                                },
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(friend.avatarUrl),
                                      radius: 30,
                                    ),
                                    if (isSelected)
                                      const Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Icon(
                                          Icons.indeterminate_check_box_sharp,
                                          color: Colors.grey,
                                          size: 24,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                friend.name,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Chia sẻ lên',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _buildShareOption(context, Icons.group, 'Nhóm', state),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShareOption(context, IconData icon, String label, state) {
    Place place = state.place;
    return Column(
      children: [
        InkWell(
          onTap: () {
            Navigator.pop(context);
            _addMarker(LatLng(place.latitude, place.longitude));
          },
          child: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blueAccent,
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

// Hàm để gửi thông tin chia sẻ cho các bạn đã chọn
  void _sendSharedLocation(Set<User> selectedFriends, state) {
    Place place = state.place;
    String note = _noteLocationController.text;
    List<int> friendIds = selectedFriends.map((e) => e.id!).toList();
    SharedLocationRequest shareLocationRequest = SharedLocationRequest(
      receiverIds: friendIds,
      latitude: place.latitude,
      longitude: place.longitude,
      note: note,
    );
    _mapBloc.add(SharedLocationEvent(shareLocationRequest));
    Fluttertoast.showToast(
        msg: "Đã gửi",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  List<PopupMenuItem<String>> _buildPopupMenuItems(state) {
    List<PopupMenuItem<String>> items = [];
    if (state.groups.length > 0) {
      items.add(
        const PopupMenuItem<String>(
          value: 'group',
          child: ListTile(
            leading: Icon(Icons.group, color: Colors.black),
            title: Text('Nhóm'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }
    return [
      ...items,
      const PopupMenuItem<String>(
        value: 'friend',
        child: ListTile(
          leading: Icon(Icons.person, color: Colors.black),
          title: Text('Bạn bè'),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
          ),
        ),
      ),
    ];
  }

  Widget _buildStartAndCancelButtons(BuildContext context, state) {
    return Wrap(
      spacing: 5.0, // Khoảng cách giữa các nút
      runSpacing: 8.0, // Khoảng cách giữa các dòng nút
      children: [
        _directionFunctionButton(
          context,
          state,
          'Bắt đầu',
          Icons.navigation,
          Colors.blueAccent,
          () {
            _draggableScrollableController.animateTo(
              0.1, // Kích thước nhỏ nhất
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            BlocProvider.of<MapBloc>(context).add(
              StartTrackingDirectionEvent(state.directionInfo!),
            );
          },
        ),
        _directionFunctionButton(
          context,
          state,
          'Hủy',
          Icons.close_outlined,
          Colors.grey,
          () {
            BlocProvider.of<MapBloc>(context).add(CompleteDirectionEvent());
          },
        ),
      ],
    );
  }

  Widget _buildCompleteButton(BuildContext context, state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _directionFunctionButton(
            context, state, 'Hoàn thành', Icons.check, Colors.blueAccent, () {
          BlocProvider.of<MapBloc>(context).add(CompleteDirectionEvent());
        }),
        const SizedBox(width: 10),
        _directionFunctionButton(context, state, 'Thoát', null, Colors.grey,
            () {
          BlocProvider.of<MapBloc>(context).add(StopTrackingDirectionEvent());
        }),
      ],
    );
  }

  Widget _directionFunctionButton(context, state, label, IconData? icon,
      Color bgColor, Function()? function) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            backgroundColor: WidgetStateProperty.all(bgColor), // Màu nền nút
            foregroundColor:
                WidgetStateProperty.all(Colors.white), // Màu văn bản và icon
          ),
          onPressed: () {
            function!();
            // Hành động khi nhấn nút
          },
          child: Row(
            children: [
              icon != null ? Icon(icon) : const SizedBox(),
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
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Header và nút đóng panel
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
            // Danh sách các loại bản đồ
            _listMapType(context, state),
            Container(
              height: 0.5, // Độ dày của đường
              color: Colors.grey, // Màu sắc của đường
            ),
            // Danh sách các giao diện bản đồ
            Container(
              height: 0.5, // Độ dày của đường
              color: Colors.grey, // Màu sắc của đường
            ),
            // Header
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: const Text("Chi tiết bản đồ"),
                  ),
                ],
              ),
            ),
            _listMapDetail(context, state),
            _listMapThemes(context, state),
          ],
        ),
      ),
    );
  }

  Widget _listMapThemes(BuildContext context, dynamic state) {
    return ExpansionTile(
      title: const Text('Giao diện bản đồ'), // Tiêu đề của mục thu gọn
      children: [
        ListTile(
          title: const Text('Standard'),
          onTap: () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapThemeEvent(MapTheme.STANDARD));
          },
        ),
        ListTile(
          title: const Text('Dark'),
          onTap: () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapThemeEvent(MapTheme.DARK));
          },
        ),
        ListTile(
          title: const Text('Retro'),
          onTap: () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapThemeEvent(MapTheme.RETRO));
          },
        ),
        ListTile(
          title: const Text('Silver'),
          onTap: () {
            BlocProvider.of<MapBloc>(context)
                .add(ChangeMapThemeEvent(MapTheme.SILVER));
          },
        ),
      ],
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

  Widget _buildBackSelectLocation(context, state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        label: const Text(
          'Quay lại',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: () {
          BlocProvider.of<MapBloc>(context).add(SelectLocationEvent(false));
        },
      ),
    );
  }

  Widget _floatingActionsButtonBuilder(context, state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!state.isEnabledSelectLocation && !state.isOnJourneyStarted)
          SizedBox(
            width: 150, // Đặt kích thước vùng chứa đủ lớn cho menu
            height: 150,
            child: CircularMenu(
              animationDuration: const Duration(milliseconds: 200),
              radius: 80,
              alignment: Alignment.bottomRight,
              toggleButtonColor: Colors.blueAccent,
              items: [
                CircularMenuItem(
                  icon: Icons.add_location_alt_outlined,
                  color: Colors.blueAccent,
                  onTap: () {
                    print('Add Location tapped');
                    BlocProvider.of<MapBloc>(context)
                        .add(SelectLocationEvent(true));
                  },
                ),
                CircularMenuItem(
                  icon: Icons.location_off_outlined,
                  color: Colors.red,
                  onTap: () {
                    print('Wrong Location tapped');
                    // Thực hiện hành động khác nếu cần
                  },
                ),
                CircularMenuItem(
                  icon: Icons.settings,
                  color: Colors.green,
                  onTap: () {
                    print('Settings tapped');
                    // Thực hiện hành động khác nếu cần
                  },
                ),
              ],
            ),
          ),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.only(right: 10),
          child: FloatingActionButton(
            heroTag: 'location',
            backgroundColor: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 10,
            onPressed: () {
              BlocProvider.of<MapBloc>(context).add(CurrentLocationEvent());
            },
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 15),
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
          'assets/icons/icon-stack.png',
          color: Colors.white,
          width: 30,
          height: 30,
        ),
      ),
    );
  }

  List<Widget> _actions(context) {
    return [
      Container(
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none_outlined,
                size: 30,
              ),
              onPressed: () {},
            ),
            Positioned(
              right: 11,
              top: 11,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
      Container(
        margin: const EdgeInsets.only(right: 16),
        child: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {},
        ),
      )
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
              height: 30, // Chiều cao của hình ảnh
              width: 30, // Chiều rộng của hình ảnh
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
              height: 30, // Chiều cao của hình ảnh
              width: 30, // Chiều rộng của hình ảnh
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

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông báo'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng AlertDialog
                _mapBloc.add(ClearMessageEvent()); // Gửi sự kiện để xử lý tiếp
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
      barrierDismissible:
          false, // Đảm bảo người dùng phải nhấn nút "OK" để đóng
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mapBloc.add(InitMapEvent());
  }

  Widget _buttonOkBottom(BuildContext context, state) {
    return Visibility(
      visible: state.isEnabledSelectLocation, // Điều kiện để hiển thị nút
      child: TextButton(
        onPressed: () async {
          // Xử lý khi bấm nút OKaw
          LatLng result = await _getCenterLocation(state);
          if (mounted) {
            // Sử dụng BuildContext nếu widget còn tồn tại
            BlocProvider.of<MapBloc>(context)
                .add(SelectedLocationEvent(LocationDto(
              latitude: result.latitude,
              longitude: result.longitude,
              name: 'Địa điểm đánh dấu',
              description: '',
            )));
          }
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Loại bỏ bo góc
          ),
        ),
        child: const Text(
          'OK',
          style: TextStyle(color: Colors.blue), // Màu chữ
        ),
      ),
    );
  }

  // Lấy tọa độ trung tâm"
  Future<LatLng> _getCenterLocation(state) async {
    LatLngBounds visibleRegion =
        await state.googleMapController.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );
    return centerLatLng;
  }

  Widget _buildTextFieldSearch(context, state) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        hintText:
            state.query.trim().isNotEmpty ? state.query : 'Tìm kiếm địa điểm',
        hintStyle: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade600,
          fontStyle: FontStyle.italic,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(
          Icons.search,
          color: Colors.blueAccent,
        ),
      ),
      onTap: () async {
        BlocProvider.of<MapBloc>(context).add(CompleteDirectionEvent());
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchScreen(),
          ),
        );
        if (result != null) {
          final place = result as Place;
          BlocProvider.of<MapBloc>(context).add(FoundLocationEvent(place));
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _mapBloc.close();
  }
}
