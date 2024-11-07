import 'package:map/dto/base_dto.dart';
import 'location_dto.dart';

class GroupLocationRequest extends BaseDto {
  List<int> groupIds;
  LocationDto location;

  GroupLocationRequest({
    int? id,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.groupIds,
    required this.location,
  }) : super(
    id: id,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // Phương thức chuyển đổi đối tượng GroupLocationRequest thành JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'groupIds': groupIds,
      'location': location.toJson(),
    };
  }

  // Phương thức tạo đối tượng GroupLocationRequest từ JSON
  factory GroupLocationRequest.fromJson(Map<String, dynamic> json) {
    return GroupLocationRequest(
      id: json['id'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      groupIds: List<int>.from(json['groupIds']),
      location: LocationDto.fromJson(json['location']),
    );
  }

  // Phương thức chuyển đối tượng GroupLocationRequest thành Map<String, dynamic>
  Map<String, dynamic> toMap() {
    final baseMap = super.toJson();
    return {
      ...baseMap,
      'groupIds': groupIds,
      'location': location.toMap(),
    };
  }
}
