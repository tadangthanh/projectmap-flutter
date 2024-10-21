import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:map/entity/direction_info.dart';
import 'package:map/entity/place.dart';

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

  Future<Place> searchPlaceDetailById(
      String placeId, LocationData startLocation) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey&language=vi&region=VN';

    final response = await http.get(Uri.parse(url));
    late Place place;

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      place = Place.fromJson(jsonResponse);

      // Sửa lại URL ảnh
      for (int i = 0; i < place.photoReferences.length; i++) {
        String photoUrl =
            'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place.photoReferences[i]}&key=$apiKey';
        // Cập nhật URL ảnh trong đối tượng Place (giả sử có một trường `photoUrl`)
        place.photoReferences[i] =
            photoUrl; // Giả sử bạn đã thêm một danh sách `photoUrls` vào model Place
      }
    } else {
      throw Exception('Failed to fetch place detail');
    }
    DirectionInfo directionInfo = await getPolylinePoints(
        LatLng(startLocation.latitude!, startLocation.longitude!),
        LatLng(place.latitude, place.longitude));
    place.directionInfo = directionInfo;
    return place; // Trả về đối tượng Place
  }

  Future<DirectionInfo> getPolylinePoints(LatLng start, LatLng end,
      {TravelMode mode = TravelMode.driving}) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineRequest polylineRequest = PolylineRequest(
      origin: PointLatLng(start.latitude, start.longitude),
      destination: PointLatLng(end.latitude, end.longitude),
      mode: mode, // Thay đổi chế độ di chuyển
    );

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: apiKey,
      request: polylineRequest,
    );
    print("duration text: ${result.durationTexts}");
    print("distanceTexts text: ${result.distanceTexts}");
    print("distanceValues text: ${result.distanceValues}");

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    Polyline polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: polylineCoordinates,
      color: Colors.blue,
      width: 5,
    );
    return DirectionInfo(
        polyline: polyline,
        distance: result.distanceTexts,
        duration: result.durationTexts);
  }
}
