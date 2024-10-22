import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/route_response.dart';
import 'package:map/entity/travel_mode_enum.dart';

import '../entity/place_prediction.dart';

class PlaceSearch {
  final String apiKey = 'AIzaSyAUWLhzZyJhxCSEiAYwSucwgZTfxU6w2Cs';

  Future<List<PlacePrediction>> getAutocomplete(String search) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&key=$apiKey&libraries=places&language=vi&region=VN';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse JSON response
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Create a list of PlacePrediction objects
      List<PlacePrediction> predictions = (jsonResponse['predictions'] as List)
          .map((predictionJson) => PlacePrediction.fromJson(predictionJson))
          .toList();

      return predictions;
    } else {
      throw Exception('Failed to fetch autocomplete predictions');
    }
  }

  Future<Place> searchPlaceDetailById(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&language=vi&region=VN&fields=formatted_address,geometry,name';
    final response = await http.get(Uri.parse(url));
    late Place place;

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      place = Place.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to fetch place detail');
    }
    return place; // Trả về đối tượng Place
  }




  Future<DirectionInfo> getPolylinePoints(LatLng start, LatLng end,
      {VehicleType mode = VehicleType.TWO_WHEELER}) async {
    PolylinePoints polylinePoints = PolylinePoints();
    Set<Polyline> polylines = {};
    final Uri url =
    Uri.parse("https://routes.googleapis.com/directions/v2:computeRoutes");

    // Tạo header
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'X-Goog-FieldMask':
      'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
      'X-Goog-Api-Key': apiKey,
    };

    // Tạo body
    final body = json.encode({
      'origin': {
        'location': {
          'latLng': {
            'latitude': start.latitude,
            'longitude': start.longitude,
          }
        }
      },
      'destination': {
        'location': {
          'latLng': {
            'latitude': end.latitude,
            'longitude': end.longitude,
          }
        }
      },
      'travelMode': mode.toString().split('.').last, // Lấy tên enum cho mode
      'polylineQuality': 'HIGH_QUALITY',
      'languageCode': 'vi',
      'computeAlternativeRoutes': true, // Tính thêm các tuyến đường phụ
    });

    // Gửi request
    final response = await http.post(url, headers: headers, body: body);

    // Kiểm tra phản hồi
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];

      // Chuyển đổi dữ liệu JSON thành danh sách các route
      Set<RouteResponse> routeResponses = routes
          .map<RouteResponse>((route) => RouteResponse.fromJson(route))
          .toSet();

      List<String> distances = [];
      List<String> durations = [];

      for (var result in routeResponses) {
        List<LatLng> polylineCoordinates = [];  // Tạo mới mỗi khi tạo một tuyến mới
        List<PointLatLng> avl =
        polylinePoints.decodePolyline(result.polyline.encodedPolyline);

        if (avl.isNotEmpty) {
          for (var point in avl) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }

        // Tạo một polyline từ các điểm tọa độ
        Polyline polyline = Polyline(
          polylineId: PolylineId('route${result.duration}'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        );
        polylines.add(polyline);

        // Thêm khoảng cách và thời gian
        distances.add('${result.distanceMeters} meters');
        durations.add('${result.duration} seconds');
      }

      // Trả về DirectionInfo chứa polyline, distance và duration
      return DirectionInfo(
          polyline: polylines, distance: distances, duration: durations);
    } else {
      // Xử lý lỗi khi không nhận được phản hồi thành công từ API
      throw Exception('Failed to load routes: ${response.body}');
    }
  }
}
