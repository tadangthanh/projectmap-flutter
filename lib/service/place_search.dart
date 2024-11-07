import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';
import 'package:map/entity/place_type.dart';
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

  Future<List<Place>> searchByNearByType(
      LocationData locationData, PlaceTypes type, int radius) async {
    // Chuyển đổi enum sang dạng String
    final String typeString = type.toString().split('.').last;
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${locationData.latitude},${locationData.longitude}&radius=$radius&type=$typeString&key=$apiKey&language=vi&region=VN&fields=formatted_address,geometry,name';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      List<Place> places = (jsonResponse['results'] as List)
          .map((placeJson) => Place.fromJsonList(placeJson))
          .toList();
      return places;
    } else {
      throw Exception('Failed to fetch nearby places');
    }
  }

  Future<DirectionInfo> getPolylinePoints(
      LatLng start,
      LatLng end,
      Function(String polylineId, String distance,
              String duration)
          onPolylineTap,
      // Sửa đổi để thêm polylineId
      {VehicleType mode = VehicleType.TWO_WHEELER}) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<Polyline> polylines = [];

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
      'travelMode': mode.toString().split('.').last,
      'polylineQuality': 'OVERVIEW',
      'languageCode': 'vi',
      'computeAlternativeRoutes': true,
    });

    // Gửi request
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final routes = data['routes'];

      Set<RouteResponse> routeResponses = routes
          .map<RouteResponse>((route) => RouteResponse.fromJson(route))
          .toSet();

      String distance = '';
      String duration = '';
      int index = 0;

      for (var result in routeResponses) {
        // tọa độ của tuyến đường
        List<LatLng> polylineCoordinates = [];
        List<PointLatLng> avl =
            polylinePoints.decodePolyline(result.polyline.encodedPolyline);

        if (avl.isNotEmpty) {
          for (var point in avl) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }
        }
        var rng = Random();
        String polylineId = rng.nextInt(10000).toString();
        // ID cho tuyến đường (sử dụng duration và index để phân biệt)
        // String polylineId = 'route${result.duration}_$index';

        // Tạo polyline màu viền (ngoài)
        Polyline outerPolyline = Polyline(
          polylineId: PolylineId('outer_$polylineId'),
          points: polylineCoordinates,
          color: index == 0 ? const Color(0xff0a11d8) : const Color(0xffababb5),
          width: index == 0 ? 10 : 8,
          // Viền ngoài rộng hơn
          zIndex: index == 0
              ? 90
              : -1, // Đảm bảo tuyến chính hiển thị trên tuyến phụ
        );

        // Tạo polyline chính bên trong
        Color polylineColor =
            index == 0 ? const Color(0xff0f53ff) : const Color(0xffbccefb);
        Polyline innerPolyline = Polyline(
          polylineId: PolylineId('inner_$polylineId'),
          points: polylineCoordinates,
          color: polylineColor,
          width: index == 0 ? 8 : 6,
          // Tuyến chính bên trong có độ rộng nhỏ hơn
          zIndex: index == 0 ? 100 : 0,
          onTap: () {
            // Truyền polylineId vào hàm onPolylineTap
            onPolylineTap(polylineId,
                result.distanceMeters.toString(), result.duration);
          },
          consumeTapEvents: true,
        );

        // Thêm cả hai polyline vào tập hợp
        polylines.add(outerPolyline);
        polylines.add(innerPolyline);

        // Lưu thông tin khoảng cách và thời gian cho polyline chính (inner)
        if(index==0){
          distance= result.distanceMeters.toString();
          duration = result.duration;
        }

        index++;
      }

      return DirectionInfo(
        polyline: polylines,
        distance: distance,
        duration: duration,
      );
    } else {
      throw Exception('Failed to load routes: ${response.body}');
    }
  }
}
