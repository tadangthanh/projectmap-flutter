

class Place {
  final String placeId;
  final String name; // Tên địa điểm
  final String formattedAddress;
  final double latitude; // Vĩ độ
  final double longitude; // Kinh độ

  Place({
    required this.placeId,
    required this.name,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });

  // Phương thức khởi tạo từ JSON
  factory Place.fromJson(Map<String, dynamic> json) {
    // Lấy tên, kinh độ và vĩ độ
    final placeId=json['result']['place_id']??'';
    final name = json['result']['name'] ?? '';
    final formattedAddress = json['result']['formatted_address'] ?? '';
    final latitude = json['result']['geometry']['location']['lat'] ?? 0.0;
    final longitude = json['result']['geometry']['location']['lng'] ?? 0.0;
    return Place(
      placeId: placeId,
      name: name,
      formattedAddress: formattedAddress,
      latitude: latitude,
      longitude: longitude
    );
  }
  factory Place.fromJsonList(Map<String, dynamic> json) {
    // Lấy tên, kinh độ và vĩ độ
    final placeId=json['place_id']??'';
    final name = json['name'] ?? '';
    final formattedAddress = json['formatted_address'] ?? '';
    final latitude = json['geometry']['location']['lat'] ?? 0.0;
    final longitude = json['geometry']['location']['lng'] ?? 0.0;
    return Place(
        placeId: placeId,
        name: name,
        formattedAddress: formattedAddress,
        latitude: latitude,
        longitude: longitude
    );
  }
  @override
  String toString() {
    return 'Place{name: $name, latitude: $latitude, longitude: $longitude';
  }
}
