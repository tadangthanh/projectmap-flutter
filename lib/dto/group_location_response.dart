import 'package:map/dto/base_dto.dart';
import 'package:map/dto/location_dto.dart';

class GroupLocationResponse extends BaseDto {
  int groupId;
  String groupName;
  List<LocationDto> locations;

  GroupLocationResponse({
    int? id,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.groupId,
    required this.groupName,
    required this.locations,
  }) : super(
    id: id,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  // Phương thức toJson để chuyển đổi đối tượng thành JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'groupId': groupId,
      'groupName': groupName,
      'locations': locations.map((location) => location.toJson()).toList(),
    };
  }

  // Phương thức fromJson để tạo đối tượng từ JSON
  factory GroupLocationResponse.fromJson(Map<String, dynamic> json) {
    return GroupLocationResponse(
      id: json['id'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      groupId: json['groupId'],
      groupName: json['groupName'],
      locations: (json['locations'] as List)
          .map((locationJson) => LocationDto.fromJson(locationJson))
          .toList(),
    );
  }

  // Phương thức fromListJson để tạo danh sách đối tượng từ danh sách JSON
  static List<GroupLocationResponse> fromListJson(List<dynamic> list) {
    return list.map((json) => GroupLocationResponse.fromJson(json)).toList();
  }
}
