import '../entity/place_prediction.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceSearch {
  Future<List<PlacePrediction>> getAutocomplete(String search) async {
    const String apiKey = 'AIzaSyAUWLhzZyJhxCSEiAYwSucwgZTfxU6w2Cs';
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

}
