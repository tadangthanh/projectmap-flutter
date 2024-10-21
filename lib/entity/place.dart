import 'package:map/entity/direction_info.dart';

class Place {
  final String placeId;
  final String name; // Tên địa điểm
  final String formattedAddress;
  final double latitude; // Vĩ độ
  final double longitude; // Kinh độ
  final List<String> photoReferences; // Danh sách đường dẫn ảnh
  late DirectionInfo  directionInfo;

  Place({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    required this.photoReferences
  });

  // Phương thức khởi tạo từ JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    // Lấy tên, kinh độ và vĩ độ
    final placeId=json['result']['place_id']??'';
    final name = json['result']['name'] ?? '';
    final formattedAddress = json['result']['formatted_address'] ?? '';
    final latitude = json['result']['geometry']['location']['lat'] ?? 0.0;
    final longitude = json['result']['geometry']['location']['lng'] ?? 0.0;

    // Lấy danh sách đường dẫn ảnh
    final List<String> photoReferences = (json['result']['photos'] as List<dynamic>)
        .map((photo) => photo['photo_reference'] as String)
        .toList();

    return Place(
      placeId: placeId,
      name: name,
      formattedAddress: formattedAddress,
      latitude: latitude,
      longitude: longitude,
      photoReferences: photoReferences
    );
  }

  @override
  String toString() {
    return 'Place{name: $name, latitude: $latitude, longitude: $longitude, photoReferences: $photoReferences}';
  }
}
