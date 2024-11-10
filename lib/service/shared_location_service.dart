import 'package:map/dto/shared_location_dto.dart';
import 'package:map/dto/shared_location_request.dart';

import '../util/request.dart';
import '../util/url.dart';

class SharedLocationService {
  Future<SharedLocationDto> shareLocation(
      SharedLocationRequest sharedLocationRequest) async {
    String url = "${Url.BASE_URL_V1}/shared-locations";
    try {
      SharedLocationDto response = SharedLocationDto.fromMap(
          await NetworkService.post(
              url: url,
              body: sharedLocationRequest.toMap(),
              headers: {'Content-Type': 'application/json'}));
      return response;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
