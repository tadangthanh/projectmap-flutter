import 'package:map/dto/base_dto.dart';
import 'package:map/dto/user_group_status.dart';
class GroupResponseDto extends BaseDto {
  String name;
  String description;
  int totalMembers;
  String role;
  List<String> permissions;
  UserGroupStatus status;

  GroupResponseDto({
    required super.id,
    required super.createdBy,
    required super.updatedBy,
    required super.createdAt,
    required super.updatedAt,
    required this.name,
    required this.description,
    required this.totalMembers,
    required this.role,
    required this.permissions,
    required this.status,
  });

  // Factory method to create an instance from a Map
  factory GroupResponseDto.fromMap(Map<String, dynamic> map) {
    return GroupResponseDto(
      id: map['id'],
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      name: map['name'],
      description: map['description'],
      totalMembers: map['totalMembers'] ?? 0,
      role: map['role'],
      permissions: List<String>.from(map['permissions'] ?? []),
      status: UserGroupStatus.values
          .firstWhere((e) => e.toString().split('.').last == map['status']),
    );
  }

  // Factory method to create an instance from JSON
  factory GroupResponseDto.fromJson(Map<String, dynamic> json) {
    return GroupResponseDto(
      id: json['id'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      name: json['name'],
      description: json['description'],
      totalMembers: json['totalMembers'] ?? 0,
      role: json['role'],
      permissions: List<String>.from(json['permissions'] ?? []),
      status: UserGroupStatus.values
          .firstWhere((e) => e.toString().split('.').last == json['status']),
    );
  }

  // Method to convert a list of JSON objects to a list of GroupResponseDto
  static List<GroupResponseDto> fromListJson(List<dynamic> list) {
    return list.map((item) => GroupResponseDto.fromMap(item)).toList();
  }

  // Method to convert the object to JSON
  @override
  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'name': name,
      'description': description,
      'totalMembers': totalMembers,
      'role': role,
      'permissions': permissions,
      'userGroupStatus': status.toString().split('.').last,
    };
  }
}
