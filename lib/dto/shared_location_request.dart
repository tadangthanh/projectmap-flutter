import 'dart:convert';

class SharedLocationRequest {
  double latitude;
  double longitude;
  List<int> receiverIds;
  String? note;

  SharedLocationRequest({
    required this.latitude,
    required this.longitude,
    required this.receiverIds,
    this.note,
  });

  // Phương thức toMap để chuyển đổi đối tượng thành Map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'receiverIds': receiverIds,
      'note': note,
    };
  }

  // Phương thức fromMap để khởi tạo đối tượng từ Map
  factory SharedLocationRequest.fromMap(Map<String, dynamic> map) {
    return SharedLocationRequest(
      latitude: map['latitude'],
      longitude: map['longitude'],
      receiverIds: List<int>.from(map['receiverIds']),
      note: map['note'],
    );
  }

  // Phương thức toJson để chuyển đổi đối tượng thành JSON
  String toJson() => json.encode(toMap());

  // Phương thức fromJson để khởi tạo đối tượng từ JSON
  factory SharedLocationRequest.fromJson(String source) =>
      SharedLocationRequest.fromMap(json.decode(source));
}
