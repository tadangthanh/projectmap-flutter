import 'package:map/dto/base_dto.dart';

class LocationDto extends BaseDto {
  double latitude;
  double longitude;
  String name;
  String description;

  LocationDto({
    int? id,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.description,
  }) : super(
    id: id,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // Phương thức chuyển đối tượng LocationDto thành JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'description': description,
    };
  }

  // Phương thức tạo đối tượng LocationDto từ JSON
  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      id: json['id'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      name: json['name'],
      description: json['description'],
    );
  }

  // Phương thức chuyển đối tượng LocationDto thành Map<String, dynamic>
  Map<String, dynamic> toMap() {
    final baseMap = super.toJson(); // Lấy baseMap từ lớp cha
    return {
      ...baseMap,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
      'description': description,
    };
  }
}
