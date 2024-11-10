import 'package:map/dto/base_dto.dart';
import 'package:map/dto/relation_ship_role.dart';

class UserSearchResponse extends BaseDto {
  final String googleId;
  final String name;
  final String email;
  final String avatarUrl;
  final bool friend;
  final RelationshipRole relationshipRole;

  UserSearchResponse({
    int? id,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.googleId,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.friend,
    required this.relationshipRole,
  }) : super(
    id: id,
    createdBy: createdBy,
    updatedBy: updatedBy,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory UserSearchResponse.fromMap(Map<String, dynamic> map) {
    return UserSearchResponse(
      id: map['id'],
      createdBy: map['createdBy'],
      updatedBy: map['updatedBy'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      googleId: map['googleId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      friend: map['friend'] ?? false,
      relationshipRole: _getRelationShipRole(map['relationshipRole']),
    );
  }

  Map<String, dynamic> toJson() {
    final baseJson = super.toJson();
    return {
      ...baseJson,
      'googleId': googleId,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'friend': friend,
      'relationshipRole': relationshipRole.toString().split('.').last,
    };
  }

  static RelationshipRole _getRelationShipRole(String? role) {
    if (role == null) {
      return RelationshipRole.NONE;
    }
    try {
      return RelationshipRole.values.firstWhere(
            (element) => element.toString().split('.').last == role,
      );
    } catch (e) {
      return RelationshipRole.NONE;
    }
  }
}
